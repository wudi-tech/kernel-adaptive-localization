function test_micro_synthetic
%TEST_MICRO_SYNTHETIC Tiny artificial fixtures, never course measurements.
component = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
guardPath = onCleanup(@() path(oldPath));
state = rng;
guardRng = onCleanup(@() rng(state));
addpath(fullfile(component, 'matlab'), ...
    fullfile(component, 'matlab', 'fingerprint'), '-begin');
X = [0.2 -0.1 0.3; 0.1 0.4 -0.2; -0.3 0.2 0.1; 0.4 0.1 0.2];
y = [0.5; -0.2; 0.3; 0.1];
Q = X(1:2, :);
models = {rls_r(struct('M', Inf)), lms_r(struct('M', Inf, 'eta', 1e-5)), ...
    Fr_lms_r(struct('M', Inf, 'eta', 1e-5, 'alpha', 0.8)), ...
    Fr_rls_r(struct('M', Inf, 'alpha', 1))};
for j = 1:numel(models)
    model = models{j};
    model.initial_p(X(1, :), y(1));
    assert(numel(model.dict) == 3);
    % The baseline RLS intentionally ignores the first target.
    if j == 1
        assert(all(model.weightVector == 0));
    end
    for i = 2:4
        model.train(X(i, :), y(i));
    end
    prediction = model.evaluate(Q);
    assert(isequal(size(prediction), [2 1]));
    assert(isreal(prediction) && all(isfinite(prediction)));
    assert(size(model.dict, 1) == 4);
end
assert(isscalar(models{1}.P));
assert(isequal(size(models{4}.P), [3 3]));
fprintf('HISTORICAL_CLASSES=PASS (4 classes, 4 updates, 2 predictions)\n');

% Separate time-series helpers: tiny arrays only, no MAT/MAIN invocation.
addpath(fullfile(component, 'matlab', 'series-benchmark'), '-begin');
curve = LMS(X', y, Q', y(1:2), 0.001, 0, true);
assert(isequal(size(curve), [4 1]) && all(isfinite(curve)));
curve = FrLMS(X', y, Q', y(1:2), 0.00075, 0.9, true);
assert(isequal(size(curve), [4 1]) && all(isfinite(curve)));
[weights, curve] = RLS(X', y, Q', y(1:2), eye(3)/100, true);
assert(isequal(size(weights), [3 1]) && all(isfinite(curve)));
[weights, curve] = FrRLS(X', y, Q', y(1:2), eye(3)/35, 1.32, true);
assert(all(isfinite(weights)) && all(isfinite(curve)));
rng(5);
noise = stblrnd(1.1, 0, 0.1, 0, [2 2]);
assert(isequal(size(noise), [2 2]) && all(isfinite(noise(:))));
fprintf('SERIES_HELPERS=PASS (4 functions; noise helper 4 samples)\n');

temp = tempname;
mkdir(temp);
guardTemp = onCleanup(@() rmdir(temp, 's'));
headers = {'x', 'y', 'RSSI A', 'RSSI B', 'RSSI C'};
training = array2table([y, y*0.5, X], 'VariableNames', headers);
testing = training(1:2, :);
writetable(training, fullfile(temp, 'train.csv'));
writetable(testing, fullfile(temp, 'test.csv'));
result = run_fingerprint_csv(fullfile(temp, 'train.csv'), fullfile(temp, 'test.csv'));
assert(isequal(size(result.mse), [4 4 2]));
assert(isequal(size(result.predictions), [2 4 2]));
assert(all(isfinite(result.mse(:))));
assert(isequal(result.training_order(:, 1), (1:4)'));
assert(isequal(sort(result.training_order(:, 2)), (1:4)'));
for axisIndex = 1:2
    for method = 1:4
        expected = mean((testing{:, axisIndex} - ...
            result.predictions(:, method, axisIndex)).^2);
        assert(abs(expected - result.mse(end, method, axisIndex)) < 1e-14);
    end
end
fprintf('CSV_WRAPPER=PASS (4 training, 2 test, both axes; paired output MSE)\n');

bad = testing;
bad.Properties.VariableNames{1} = 'wrong';
writetable(bad, fullfile(temp, 'bad.csv'));
failedAsExpected = false;
try
    run_fingerprint_csv(fullfile(temp, 'bad.csv'), fullfile(temp, 'test.csv'));
catch exception
    failedAsExpected = strcmp(exception.identifier, 'wifi:Schema');
end
assert(failedAsExpected);
fprintf('SCHEMA_REJECTION=PASS\n');
fprintf('WIFI_MICRO_SYNTHETIC=PASS; no course data, full simulation, or hardware run\n');
end

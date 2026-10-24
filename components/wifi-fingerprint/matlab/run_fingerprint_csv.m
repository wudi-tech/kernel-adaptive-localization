function result = run_fingerprint_csv(trainFile, testFile)
%RUN_FINGERPRINT_CSV Portable reader around the unchanged historical classes.
% No measurements are bundled. Supply authorized x,y,RSSI A/B/C CSV files.
% This function does not repair historical update rules or tune parameters.
root = fileparts(mfilename('fullpath'));
oldPath = path;
pathGuard = onCleanup(@() path(oldPath));
rngState = rng;
rngGuard = onCleanup(@() rng(rngState));
addpath(fullfile(root, 'fingerprint'), '-begin');
train = read_private_csv(trainFile);
test = read_private_csv(testFile);
n = size(train, 1);
result.methods = {'RLS', 'LMS', 'FrLMS', 'FrRLS'};
result.mse = zeros(n, 4, 2);
result.predictions = zeros(size(test, 1), 4, 2);
result.training_order = zeros(n, 2);
for axisIndex = 1:2
    rng(5);
    if axisIndex == 1
        randperm(16); % Historical x script consumes this unused permutation.
        order = 1:n;
    else
        order = randperm(n);
    end
    result.training_order(:, axisIndex) = order(:);
    models = {rls_r(struct('M', Inf)), ...
        lms_r(struct('M', Inf, 'eta', 0.00001)), ...
        Fr_lms_r(struct('M', Inf, 'eta', 0.00001, 'alpha', 0.8)), ...
        Fr_rls_r(struct('M', Inf, 'alpha', 1))};
    for method = 1:4
        model = models{method};
        for update = 1:n
            row = order(update);
            if update == 1
                model.initial_p(train(row, 3:5), train(row, axisIndex));
            else
                model.train(train(row, 3:5), train(row, axisIndex));
            end
            prediction = model.evaluate(test(:, 3:5));
            if ~isreal(prediction) || any(~isfinite(prediction(:)))
                error('wifi:NonfinitePrediction', ...
                    'Historical update produced nonfinite or complex predictions.');
            end
            result.mse(update, method, axisIndex) = ...
                mean((test(:, axisIndex) - prediction).^2);
        end
        result.predictions(:, method, axisIndex) = prediction;
    end
end
result.scope = 'Historical updates; private CSV input; no accuracy certification';
end

function values = read_private_csv(filename)
tableData = readtable(filename, 'VariableNamingRule', 'preserve');
expected = {'x', 'y', 'RSSI A', 'RSSI B', 'RSSI C'};
if ~isequal(tableData.Properties.VariableNames, expected)
    error('wifi:Schema', 'CSV header must be x,y,RSSI A,RSSI B,RSSI C.');
end
values = table2array(tableData);
if ~isnumeric(values) || isempty(values) || size(values, 2) ~= 5 || ...
        ~isreal(values) || any(~isfinite(values(:)))
    error('wifi:Numeric', 'CSV must contain nonempty, finite numeric rows.');
end
end

function report = check_static
%CHECK_STATIC Report parser/analyzer messages without editing historical code.
component = fileparts(fileparts(mfilename('fullpath')));
files = [dir(fullfile(component, 'matlab', '**', '*.m')); ...
    dir(fullfile(component, 'tests', '*.m'))];
report = struct('file', {}, 'message_count', {}, 'messages', {});
for i = 1:numel(files)
    filename = fullfile(files(i).folder, files(i).name);
    messages = checkcode(filename, '-id');
    relative = strrep(filename(numel(component)+2:end), '\', '/');
    report(i).file = relative;
    report(i).message_count = numel(messages);
    report(i).messages = messages;
end
fprintf('STATIC_FILES=%d; ANALYZER_MESSAGES=%d\n', ...
    numel(files), sum([report.message_count]));
fprintf('Historical warnings are recorded, not silently repaired.\n');
end

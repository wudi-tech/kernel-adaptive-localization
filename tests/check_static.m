function report = check_static
% 只分析代码和类元信息；不调用 initial_p、train 或 evaluate，不读取课程数据。
root = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
cleanup = onCleanup(@() path(oldPath));
addpath(root,'-begin');
files = [dir(fullfile(root,'*.m'));dir(fullfile(root,'tests','*.m'))];
messageCount = 0;
for i = 1:numel(files)
    messages = checkcode(fullfile(files(i).folder,files(i).name),'-id');
    messageCount = messageCount+numel(messages);
    for j = 1:numel(messages)
        fprintf('%s:%d %s %s\n',files(i).name,messages(j).line,messages(j).id,messages(j).message);
    end
end
names = {'KRLS','KLMS','FrKLMS','FrKRLS','KRGMC'};
required = {'initial_p','train','evaluate','model'};
for i = 1:numel(names)
    info = meta.class.fromName(names{i});
    assert(~isempty(info),'KAF:MissingClass','无法解析算法类。');
    assert(ismember('handle',{info.SuperclassList.Name}),'算法必须继承 handle。');
    assert(all(ismember(required,{info.MethodList.Name})),'算法方法不完整。');
end
report = struct('matlabFiles',numel(files),'checkcodeMessages',messageCount, ...
    'classes',numel(names),'trainingExecuted',false,'courseDataRead',false);
fprintf('STATIC_FILES=%d; CHECKCODE_MESSAGES=%d; CLASSES=%d; TRAINING=NOT_RUN; COURSE_DATA=NOT_READ\n', ...
    report.matlabFiles,report.checkcodeMessages,report.classes);
assert(messageCount==0,'KAF:StaticMessages','请检查静态分析消息。');
end

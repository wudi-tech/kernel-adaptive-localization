function test_ppt_class_structure
% PPT 结构验收：每个算法必须是独立 handle 类，并具有统一方法。
root = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
cleanup = onCleanup(@() path(oldPath));
addpath(root,'-begin');
names = {'KRLS','KLMS','FrKLMS','FrKRLS','KRGMC'};
required = {'initial_p','train','evaluate','model'};
for i = 1:numel(names)
    assert(isfile(fullfile(root,[names{i},'.m'])), ...
        'PPTStructure:MissingClass','缺少 PPT 的独立算法类：%s。',names{i});
    constructor = str2func(names{i});
    kaf = constructor(struct('sigma',1,'gam',0.1,'eta',0.2, ...
        'p',1.5,'alpha',0.8,'ker',2,'M',Inf,'kerneltype','gauss'));
    assert(isa(kaf,'handle'),'算法必须继承 handle。');
    assert(all(ismember(required,methods(kaf))),'算法方法接口与 PPT 不一致。');
    assert(isequal(kaf.evaluate([0.1 0.2;0.3 0.4]),zeros(2,1)));
    kaf.initial_p([0.1 0.2],0.6);
    kaf.train([0.3 0.4],0.8);
    assert(all(isfinite(kaf.evaluate([0.2 0.3;0.5 0.6]))));
    [dict,weight] = kaf.model;
    assert(isequal(size(dict),[2 2]) && isequal(size(weight),[2 1]));
end
assert(isfile(fullfile(root,'MAIN_x.m')) && isfile(fullfile(root,'MAIN_y.m')));
assert(~isfolder(fullfile(root,'+iotcurves')), ...
    '活动代码仍包含合并算法包。');
fprintf('PPT_CLASS_STRUCTURE=PASS; CLASSES=5; METHODS=initial_p/train/evaluate/model\n');
end

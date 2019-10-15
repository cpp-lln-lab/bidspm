function test_getData()
% Small test to ensure that getData returns what we asked for

addpath(genpath(fullfile(pwd, '..')))

opt.derivativesDir = fullfile(pwd, 'dummyData');
opt.taskName = 'vismotion';


%% Get all groups all subjects
opt.groups = {''};
opt.subjects = {[], []};

[group] = getData(opt);
assert(strcmp(group(1).name, ''))
assert(group.numSub == 8)
assert(isequal(group.subNumber, {'blind01'  'blind02'  'cat01'  'cat02'  'cont01'  'cont02'  'ctrl01'  'ctrl02'}))

%% Get some subjects of some groups
opt.groups = {'cont', 'cat'};
opt.subjects = {1:2, 2};

[group] = getData(opt);
assert(strcmp(group(1).name, 'cont'))
assert(group(1).numSub == 2)
assert(isequal(group(1).subNumber, {'cont01' 'cont02'}))
assert(strcmp(group(2).name, 'cat'))
assert(group(2).numSub == 1)
assert(isequal(group(2).subNumber, {'cat02'}))

%% Get second subjects of each group
% opt.groups = {''};
% opt.subjects = {2};
% not implemented yet

end
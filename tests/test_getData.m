function test_suite = test_getData %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getDataBasic()
    % Small test to ensure that getData returns what we asked for

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.taskName = 'vismotion';
    opt.zeropad = 2;

    %% Get all groups all subjects
    opt.groups = {''};
    opt.subjects = {[]};

    [group] = getData(opt);

    assert(isequal(group(1).name, ''));
    assert(isequal(group.numSub, 6));
    assert(isequal(group.subNumber, ...
                   {'01' '02' 'blind01' 'blind02' 'ctrl01' 'ctrl02'}));

    %% Get some subjects of some groups
    opt.groups = {'ctrl', 'blind'};
    opt.subjects = {[1 2], 2};

    [group] = getData(opt);

    assert(isequal(group(1).name, 'ctrl'));
    assert(isequal(group(1).numSub, 2));
    assert(isequal(group(1).subNumber, {'ctrl01' 'ctrl02'}));
    assert(isequal(group(2).name, 'blind'));
    assert(isequal(group(2).numSub, 1));
    assert(isequal(group(2).subNumber, {'blind02'}));

    %% Get all subjects of some groups
    opt.groups = {'ctrl', 'blind'};
    opt.subjects = {[], []};

    [group] = getData(opt);

    assert(isequal(group(1).name, 'ctrl'));
    assert(isequal(group(1).numSub, 2));
    assert(isequal(group(1).subNumber, {'ctrl01' 'ctrl02'}));
    assert(isequal(group(2).name, 'blind'));
    assert(isequal(group(2).numSub, 2));
    assert(isequal(group(2).subNumber, {'blind01' 'blind02'}));

    %% Get some specified subjects
    opt.groups = {''};
    opt.subjects = {'01', 'ctrl02', 'blind02'};

    [group] = getData(opt);

    assert(isequal(group(1).name, ''));
    assert(isequal(group(1).numSub, 3));
    assert(isequal(group(1).subNumber,  {'01', 'ctrl02', 'blind02'}));

    %% Only get anat metadata
    opt.groups = {''};

    opt.subjects = {'01'};

    [~, opt] = getData(opt, [], 'T1w');

    assert(isequal(opt.metadata.RepetitionTime, 2.3));

end


function test_getDataErrorTask()
    % Small test to ensure that getData returns what we asked for

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.taskName = 'testTask';
    opt.zeropad = 2;

    %% Get all groups all subjects
    opt.groups = {''};
    opt.subjects = {[]};

        assertExceptionThrown( ...
                          @()getData(opt), ...
                          'getData:noMatchingTask');
    
end

function test_getDataErrorSubject()
    % Small test to ensure that getData returns what we asked for

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.taskName = 'vismotion';

    %% Get all groups all subjects
    opt.groups = {''};
    opt.subjects = {'03'};

        assertExceptionThrown( ...
                          @()getData(opt), ...
                          'getData:noMatchingSubject');
    
end

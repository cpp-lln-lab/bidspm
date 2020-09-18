function test_suite = test_getInfo %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getInfoBasic()
    % Small test to ensure that getSliceOrder returns what we asked for

    % write tests for when no session or only one run

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives');
    opt.groups = {''};
    opt.subjects = {[], []};

    %% Get sessions from BIDS
    opt.taskName = 'vismotion';
    subID = 'ctrl01';
    info = 'sessions';
    [~, opt, BIDS] = getData(opt);
    sessions = getInfo(BIDS, subID, opt, info);
    assert(all(strcmp(sessions, {'01' '02'})));

    %% Get runs from BIDS
    opt.taskName = 'vismotion';
    subID = 'ctrl01';
    info = 'runs';
    session =  '01';
    [~, opt, BIDS] = getData(opt);
    runs = getInfo(BIDS, subID, opt, info, session);
    assert(all(strcmp(runs, {'1' '2'})));

    %% Get runs from BIDS when no run in filename
    opt.taskName = 'vislocalizer';
    subID = 'ctrl01';
    info = 'runs';
    session =  '01';
    [~, opt, BIDS] = getData(opt);
    runs = getInfo(BIDS, subID, opt, info, session);
    assert(strcmp(runs, {''}));

    %% Get filename from BIDS
    opt.taskName = 'vismotion';
    subID = 'ctrl01';
    session =  '01';
    run = '1';
    info = 'filename';
    [~, opt, BIDS] = getData(opt);
    filename = getInfo(BIDS, subID, opt, info, session, run, 'bold');
    FileName = fullfile(fileparts(mfilename('fullpath')), 'dummyData',  ...
        'derivatives', 'SPM12_CPPL', ...
        ['sub-' subID], ['ses-' session], 'func', ...
        ['sub-' subID, ...
        '_ses-' session, ...
        '_task-' opt.taskName, ...
        '_run-' run, ...
        '_bold.nii']);

    assert(strcmp(filename{1}, FileName));

end

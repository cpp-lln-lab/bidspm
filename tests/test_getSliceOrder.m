function test_suite = test_getSliceOrder %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getSliceOrderBasic()
    % Small test to ensure that getSliceOrder returns what we asked for

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.groups = {''};
    opt.subjects = {[], []};

    %% Get slice order from BIDS
    sliceOrder = repmat( ...
                        [0.5475; ...
                         0; ...
                         0.3825; ...
                         0.0550; ...
                         0.4375; ...
                         0.1100; ...
                         0.4925; ...
                         0.2200; ...
                         0.6025; ...
                         0.2750; ...
                         0.6575; ...
                         0.3275; ...
                         0.7100; ...
                         0.1650], [3, 1]);

    opt.taskName = 'vismotion';
    [~, opt] = getData(opt);
    BIDS_sliceOrder = getSliceOrder(opt, 0);
    assert(isequal(sliceOrder, BIDS_sliceOrder));

    %% Get empty slice order from BIDS
    opt.taskName = 'vislocalizer';
    [~, opt] = getData(opt);
    BIDS_sliceOrder = getSliceOrder(opt, 0);
    assert(isempty(BIDS_sliceOrder));

    %% Get slice order from options
    opt.STC_referenceSlice = 1000;
    opt.sliceOrder = 0:250:2000;
    opt.taskName = 'vislocalizer';
    [~, opt] = getData(opt);
    BIDS_sliceOrder = getSliceOrder(opt, 0);
    assert(isequal(BIDS_sliceOrder, opt.sliceOrder));

end

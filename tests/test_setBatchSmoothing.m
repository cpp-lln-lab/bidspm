function test_suite = test_setBatchSmoothing %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchSmoothingBasic()

    % TODO
    % need a test with several sessions and runs

    subID = '01';

    funcFWHM = 6;

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
                           'MoAE', 'output', 'MoAEpilot');
    opt.taskName = 'auditory';

    opt = checkOptions(opt);

    [~, opt, BIDS] = getData(opt);

    % create dummy normalized file
    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subID, ...
                        'task', opt.taskName, ...
                        'type', 'bold');
    [filepath, filename, ext] = fileparts(fileName{1});
    fileName = fullfile( ...
                        filepath, ...
                        [spm_get_defaults('normalise.write.prefix') filename ext]);
    system(sprintf('touch %s', fileName));

    matlabbatch = [];
    matlabbatch = setBatchSmoothing(BIDS, opt, subID, funcFWHM);

    expectedBatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
    expectedBatch{1}.spm.spatial.smooth.dtype = 0;
    expectedBatch{1}.spm.spatial.smooth.im = 0;
    expectedBatch{1}.spm.spatial.smooth.prefix = ...
        [spm_get_defaults('smooth.prefix'), '6'];
    expectedBatch{1}.spm.spatial.smooth.data{1} = fileName;

    assertEqual( ...
                matlabbatch{1}.spm.spatial.smooth, ...
                expectedBatch{1}.spm.spatial.smooth);

end

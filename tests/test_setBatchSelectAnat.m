function test_suite = test_setBatchSelectAnat %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchSelectAnatBasic()

    % TODO
    % add test to check if anat is not in first session
    % add test to check if anat is not a T1w

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
                           'MoAE', 'output', 'MoAEpilot');
    opt.taskName = 'auditory';

    opt = checkOptions(opt);

    [~, opt, BIDS] = getData(opt);

    subID = '01';

    matlabbatch = [];
    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID);

    expectedBatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';

    anatFile = spm_select('FPlist', ...
                          fullfile( ...
                                   opt.dataDir, '..', ...
                                   'derivatives', ...
                                   'SPM12_CPPL', ...
                                   'sub-01', ...
                                   'anat'), ...
                          'sub-01_T1w.nii');
    expectedBatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

    assertEqual(matlabbatch, expectedBatch);

end

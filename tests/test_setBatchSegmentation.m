function test_suite = test_setBatchSegmentation %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchSegmentationBasic()

    spmLocation = spm('dir');

    addpath(fullfile(spmLocation, 'matlabbatch'));

    matlabbatch = [];
    matlabbatch = setBatchSegmentation(matlabbatch);

    expectedBatch = returnExpectedBatch(spmLocation);

    assertEqual(expectedBatch, matlabbatch);

end

function expectedBatch = returnExpectedBatch(spmLocation)

    expectedBatch = [];

    expectedBatch{end + 1}.spm.spatial.preproc.channel.vols(1) = ...
        cfg_dep('Named File Selector: Structural(1) - Files', ...
        substruct( ...
        '.', 'val', '{}', {1}, ...
        '.', 'val', '{}', {1}, ...
        '.', 'val', '{}', {1}, ...
        '.', 'val', '{}', {1}), ...
        substruct('.', 'files', '{}', {1}));
    expectedBatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
    expectedBatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
    expectedBatch{end}.spm.spatial.preproc.channel.write = [0 1];

    expectedBatch{end}.spm.spatial.preproc.tissue(1).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',1']};
    expectedBatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
    expectedBatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
    expectedBatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.tissue(2).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',2']};
    expectedBatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
    expectedBatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
    expectedBatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.tissue(3).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',3']};
    expectedBatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
    expectedBatch{end}.spm.spatial.preproc.tissue(3).native = [1 1];
    expectedBatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.tissue(4).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',4']};
    expectedBatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
    expectedBatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
    expectedBatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.tissue(5).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',5']};
    expectedBatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
    expectedBatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
    expectedBatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.tissue(6).tpm = ...
        {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',6']};
    expectedBatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
    expectedBatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
    expectedBatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];

    expectedBatch{end}.spm.spatial.preproc.warp.mrf = 1;
    expectedBatch{end}.spm.spatial.preproc.warp.cleanup = 1;
    expectedBatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    expectedBatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
    expectedBatch{end}.spm.spatial.preproc.warp.fwhm = 0;
    expectedBatch{end}.spm.spatial.preproc.warp.samp = 3;
    expectedBatch{end}.spm.spatial.preproc.warp.write = [1 1];

end

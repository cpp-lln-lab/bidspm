function test_suite = test_setBatchCoregistration %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchCoregistrationBasic()

    % necessarry to deal with SPM module dependencies
    spm_jobman('initcfg')

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives');
    opt.taskName = 'vismotion';
    [~, opt, BIDS] = getData(opt);
    subID = '02';

    matlabbatch = {};
    matlabbatch = setBatchCoregistration(matlabbatch, BIDS, subID, opt);    

    nbRuns = 4;
    expectedBatch = returnExpectedBatch(nbRuns);
    assertEqual(matlabbatch, expectedBatch);
    
end

function expectedBatch = returnExpectedBatch(nbRuns)

    expectedBatch = {};

    expectedBatch{end + 1}.spm.spatial.coreg.estimate.ref(1) = cfg_dep;
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).tname = 'Reference Image';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).name = 'class';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).value = 'cfg_files';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).name = 'strtype';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).value = 'e';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).sname = ...
        'Named File Selector: Structural(1) - Files';
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).src_exbranch = ...
        substruct( ...
                  '.', 'val', '{}', {1}, ...
                  '.', 'val', '{}', {1});
    expectedBatch{end}.spm.spatial.coreg.estimate.ref(1).src_output = ...
        substruct('.', 'files', '{}', {1});

    expectedBatch{end}.spm.spatial.coreg.estimate.source(1) = cfg_dep;
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).tname = 'Source Image';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).name = 'filter';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).value = 'image';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).name = 'strtype';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).value = 'e';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).sname = ...
        'Realign: Estimate & Reslice: Mean Image';
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).src_exbranch = ...
        substruct( ...
                  '.', 'val', '{}', {2}, ...
                  '.', 'val', '{}', {1}, ...
                  '.', 'val', '{}', {1}, ...
                  '.', 'val', '{}', {1});
    expectedBatch{end}.spm.spatial.coreg.estimate.source(1).src_output = ...
        substruct('.', 'rmean');

    for iRun = 1:nbRuns
        
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun) = cfg_dep;
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).tname = 'Other Images';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).tgt_spec{1}(1).name = ...
            'filter';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).tgt_spec{1}(1).value = ...
            'image';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).tgt_spec{1}(2).name = ...
            'strtype';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).tgt_spec{1}(2).value = ...
            'e';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).sname = ...
            ['Realign: Estimate & Reslice: Realigned Images (Sess ' num2str(iRun) ')'];
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).src_exbranch = ...
            substruct( ...
                      '.', 'val', '{}', {2}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1}, ...
                      '.', 'val', '{}', {1});
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun).src_output = ...
            substruct( ...
                      '.', 'sess', '()', {iRun}, ...
                      '.', 'cfiles');
    end

end

function test_suite = test_setBatchCoregistration %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchCoregistrationBasic()
    
    spmLocation = spm('dir');
    
    addpath(fullfile(spmLocation, 'matlabbatch'))

    for sesCounter = 0:2
        matlabbatch = {};
        matlabbatch = setBatchCoregistration(matlabbatch, sesCounter);
        expectedBatch = returnExpectedBatch(sesCounter);
        assertEqual(expectedBatch, matlabbatch);
    end
    
end


function expectedBatch = returnExpectedBatch(sesCounter)
    
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
    
    for iSes = 1:sesCounter - 1 % '-1' because I added 1 extra session to ses_counter
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes) = cfg_dep;
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).tname = 'Other Images';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(1).name = ...
            'filter';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(1).value = ...
            'image';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(2).name = ...
            'strtype';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(2).value = ...
            'e';
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).sname = ...
            ['Realign: Estimate & Reslice: Realigned Images (Sess ' (iSes) ')'];
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).src_exbranch = ...
            substruct( ...
            '.', 'val', '{}', {2}, ...
            '.', 'val', '{}', {1}, ...
            '.', 'val', '{}', {1}, ...
            '.', 'val', '{}', {1});
        expectedBatch{end}.spm.spatial.coreg.estimate.other(iSes).src_output = ...
            substruct( ...
            '.', 'sess', '()', {iSes}, ...
            '.', 'cfiles');
    end

end
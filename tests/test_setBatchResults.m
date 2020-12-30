function test_suite = test_setBatchResults %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchResultsBasic()
    
    iStep = 1;
    iCon = 1;
    
    result.dir = pwd;
    result.label = '01';
    result.nbSubj = 1;
    result.contrastNb = 1;

    matlabbatch = [];
    matlabbatch = setBatchResults(matlabbatch, result);

    expectedBatch = returnBasicExpectedResultsBatch();
    
    assertEqual(matlabbatch, expectedBatch);
    
end

function test_setBatchResultsExport()
    
    iStep = 1;
    iCon = 1;
    
    opt.result.Steps.Output.png = true;
    opt.result.Steps.Output.csv = true;
    opt.result.Steps.Output.thresh_spm = true;
    opt.result.Steps.Output.montage =  true;
    opt.result.Steps.Output.NIDM_results =  true;
    
    opt.space = 'individual';
    
    result.Output =  opt.result.Steps(iStep).Output;
    result.space = opt.space;
    
    result.dir = pwd;
    result.label = '01';
    result.nbSubj = 1;
    result.contrastNb = 1;
    
    matlabbatch = [];
    matlabbatch = setBatchResults(matlabbatch, result);

    expectedBatch = returnBasicExpectedResultsBatch();
    
    expectedBatch{end}.spm.stats.results.export{1}.png = true;
    expectedBatch{end}.spm.stats.results.export{2}.csv = true;
    expectedBatch{end}.spm.stats.results.export{3}.tspm.basename = '';
    
    expectedBatch{end}.spm.stats.results.export{end + 1}.nidm.modality = 'FMRI';
    expectedBatch{end}.spm.stats.results.export{end}.nidm.refspace = 'ixi';
    expectedBatch{end}.spm.stats.results.export{end}.nidm.refspace = 'subject';
    expectedBatch{end}.spm.stats.results.export{end}.nidm.group.nsubj = 1;
    expectedBatch{end}.spm.stats.results.export{end}.nidm.group.label = '01';
      
    assertEqual(matlabbatch, expectedBatch);
    
end

function expectedBatch = returnBasicExpectedResultsBatch()
      
    expectedBatch = {};
    expectedBatch{end + 1}.spm.stats.results.spmmat = {fullfile(pwd, 'SPM.mat')};
    
    expectedBatch{end}.spm.stats.results.conspec.titlestr = '';
    expectedBatch{end}.spm.stats.results.conspec.contrasts = 1;
    expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';
    expectedBatch{end}.spm.stats.results.conspec.thresh = 0.05;
    expectedBatch{end}.spm.stats.results.conspec.extent = 0;
    expectedBatch{end}.spm.stats.results.conspec.conjunction = 1;
    expectedBatch{end}.spm.stats.results.conspec.mask.none = true();
    
    expectedBatch{end}.spm.stats.results.units = 1;
    
    expectedBatch{end}.spm.stats.results.export = [];

end
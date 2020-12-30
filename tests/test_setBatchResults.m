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
    
    results.dir = pwd;
    results.label = '01';
    results.nbSubj = 1;
    results.contrastNb = 1;
    
    opt.result.Steps  = returnDefaultResultsStructureBasic();
    
    matlabbatch = [];
    matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results);
    
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
    
    expectedBatch{end}.spm.stats.results.export{1}.png = true;
    expectedBatch{end}.spm.stats.results.export{2}.csv = true;
    expectedBatch{end}.spm.stats.results.export{3}.tspm.basename = '';
    
    assertEqual(matlabbatch, expectedBatch);
    
end
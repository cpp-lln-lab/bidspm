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
    matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results)
    
end
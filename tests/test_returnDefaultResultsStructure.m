% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_returnDefaultResultsStructure %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_returnDefaultResultsStructureBasic()
    
    results  = returnDefaultResultsStructureBasic();
    
    expected.Level=  ''; 

    expected.Contrasts.Name = '';
    expected.Contrasts.Mask = false();
    expected.Contrasts.MC = 'FWE'; 
    expected.Contrasts.p = 0.05;
    expected.Contrasts.k = 0;

    expected.Output.png = false();
    expected.Output.csv = false();
    expected.Output.thresh_spm = false();
    expected.Output.montage = false();
    expected.Output.NIDM_results = false();
    
    assertEqual(results, expected)
    
end
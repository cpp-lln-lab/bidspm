function test_suite = test_setBatchRealign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchRealignBasic()
    
    % TODO
    % need a test with several sessions and runs

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
        'MoAE', 'output', 'MoAEpilot');
    opt.taskName = 'auditory';
    
    [~, opt, BIDS] = getData(opt);

    subID = '01';

    matlabbatch = [];
    matlabbatch = setBatchRealign(matlabbatch, BIDS, subID, opt);

    expectedBatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
    expectedBatch{end}.spm.spatial.realign.estwrite.roptions.which = [0 1];

    runCounter = 1;
    for iSes = 1
        fileName = spm_BIDS(BIDS, 'data', ...
                            'sub', subID, ...
                            'task', opt.taskName, ...
                            'type', 'bold');

        expectedBatch{1}.spm.spatial.realign.estwrite.data{iSes} = cellstr(fileName);
    end
    
    matlabbatch{1}.spm.spatial.realign.estwrite.data{1}
    expectedBatch{1}.spm.spatial.realign.estwrite.data{1}

    assertEqual(matlabbatch, expectedBatch);

end

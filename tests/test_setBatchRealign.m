function test_suite = test_setBatchRealign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchRealignBasic()

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.taskName = 'vismotion';
    [~, opt, BIDS] = getData(opt);

    subID = '02';
    matlabbatch = setBatchRealignReslice(BIDS, opt, subID);

    expectedBatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};

    runCounter = 1;
    for iSes = 1:2
        fileName = spm_BIDS(BIDS, 'data', ...
                            'sub', subID, ...
                            'ses', sprintf('0%i', iSes), ...
                            'task', opt.taskName, ...
                            'type', 'bold');

        for iFile = 1:numel(fileName)
            [pth, nam, ext] = spm_fileparts(fileName{iFile});
            fileName{iFile} = fullfile(pth, ['a' nam ext]);
        end

        expectedBatch{1}.spm.spatial.realign.estwrite.data{iSes} = cellstr(fileName);
    end

    assertEqual(matlabbatch, expectedBatch);

end

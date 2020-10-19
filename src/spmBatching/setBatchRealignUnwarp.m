% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchRealignUnwarp(BIDS, opt, subID)
    % [matlabbatch] = setBatchRealignUnwarp(matlabbatch, BIDS, subID, opt)

    % identify sessions for this subject
    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    for iSes = 1:nbSessions

        allFiles = {};

        [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

            [fileName, subFuncDataDir] = getBoldFilename( ...
                                                         BIDS, ...
                                                         subID, sessions{iSes}, runs{iRun}, opt);

            % check that the file with the right prefix exist
            prefix = getPrefix('preprocess', opt);
            file = inputFileValidation(subFuncDataDir, prefix, fileName);

            if numel(file) > 1
                errorStruct.identifier = 'setBatchRealignUnwarp:tooManyFiles';
                errorStruct.message = 'This should only get on file.';
                error(errorStruct);
            end

            fprintf(1, ' %s\n', file{1});

            allFiles{end + 1, 1} = file{1}; %#ok<*AGROW>

        end

        matlabbatch{1}.spm.spatial.realignunwarp.data(iSes).scans = allFiles;
        matlabbatch{1}.spm.spatial.realignunwarp.data(iSes).pmscan = '';
        
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

    end

    %%

    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 1;
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 2;
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    %     matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = '';
    %
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    %
    %     matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 3;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    %     matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    %     matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

end

% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, subID, opt, action)
    % [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, subID, opt, action)
    %
    % to set the batch in a spatial preprocessing pipeline
    %
    % Assumption about the order of the sessions: 

    if nargin < 5 || isempty(action)
        action = 'realign';
    end

    if strcmp(action, 'realign')
        matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
        matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    elseif strcmp(action, 'realignReslice')
        matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    elseif strcmp(action, 'realignUnwarp')
        matlabbatch{end + 1}.spm.spatial.realignunwarp.eoptions.weight = {''};
        matlabbatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    end

    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    runCounter = 1;

    for iSes = 1:nbSessions

        % get all runs for that subject across all sessions
        [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

            % get the filename for this bold run for this task
            [fileName, subFuncDataDir] = getBoldFilename( ...
                                                         BIDS, ...
                                                         subID, ...
                                                         sessions{iSes}, ...
                                                         runs{iRun}, ...
                                                         opt);

            % check that the file with the right prefix exist and we get and
            % save its voxeldimension
            prefix = getPrefix('preprocess', opt);
            file = validationInputFile(subFuncDataDir, fileName, prefix);
            [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName);

            if numel(file) > 1
                errorStruct.identifier = 'setBatchRealign:tooManyFiles';
                errorStruct.message = 'This should only get on file.';
                error(errorStruct);
            end

            fprintf(1, ' %s\n', file{1});

            if strcmp(action, 'realignUnwarp')
                matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).pmscan = '';
                matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).scans = file;
            else
                matlabbatch{end}.spm.spatial.realign.estwrite.data{1, runCounter} = file;
            end

            runCounter = runCounter + 1;
        end

    end

    %% defaults
    % The following lines are commented out because those parameters
    % can be set in the spm_my_defaults.m

    % -----------------
    % REALIGN
    % REALIGN & RESLICE
    % -----------------
    %
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.sep = 2;
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    %
    % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.interp = 3;
    % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.mask = 1;

    % ----------------
    % REALIGN & UNWARP
    % ----------------
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 1;
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 2;
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    %
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    %
    %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 3;
    %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;

end

function matlabbatch = setBatchSubjectLevelGLMSpec(varargin)

    [BIDS, opt, subID, funcFWHM, isMVPA] =  deal(varargin{:});

    % Check the slice timing information is not in the metadata and not added
    % manually in the opt variable.
    % Necessary to make sure that the reference slice used for slice time
    % correction is the one we center our model on
    sliceOrder = getSliceOrder(opt, 0);

    if isempty(sliceOrder)
        % no slice order defined here so we fall back on using the number of
        % slice in the first bold imageBIDS, opt, subID, funcFWHM, iSes, iRun
        % to set the number of time bins we will use to upsample our model
        % during regression creation
        fileName = spm_BIDS(BIDS, 'data', ...
            'sub', subID, ...
            'type', 'bold');
        fileName = strrep(fileName{1}, '.gz', '');
        hdr = spm_vol(fileName);
        % we are assuming axial acquisition here
        sliceOrder = 1:hdr(1).dim(3);
    end

    %%
    matlabbatch = [];

    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';

    % get TR from metadata
    TR = opt.metadata.RepetitionTime;
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;

    % number of times bins
    nbTimeBins = numel(unique(sliceOrder));
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nbTimeBins;

    refBin = floor(nbTimeBins / 2);
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refBin;

    % Create ffxDir if it doesnt exist
    % If it exists, issue a warning that it has been overwritten
    ffxDir = getFFXdir(subID, funcFWHM, opt, isMVPA);
    if exist(ffxDir, 'dir') %
        warning('overwriting directory: %s \n', ffxDir);
        rmdir(ffxDir, 's');
        mkdir(ffxDir);
    end
    matlabbatch{1}.spm.stats.fmri_spec.dir = {ffxDir};

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];

    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;

    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};

    % The following lines are commented out because those parameters
    % can be set in the spm_my_defaults.m
    %                 matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % identify sessions for this subject
    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    sesCounter = 1;
    for iSes = 1:nbSessions

        % get all runs for that subject across all sessions
        [~, nbRuns] = ...
            getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

            % get functional files
            fullpathBoldFileName = getFunctionalFiles(BIDS, opt, funcFWHM, iSes, iRun);
            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).scans = ...
                cellstr(fullpathBoldFileName);

            % get stimuli onset time file
            fullpathOnsetFileName = ...
                createAndReturnOnsetFile(opt, fullpathBoldFileName, isMVPA);
            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi = ...
                cellstr(fullpathOnsetFileName);

            % get realignment parameters
            realigntParamFile = getRealignParamFile(opt, funcFWHM, fullpathBoldFileName);
            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = ...
                cellstr(realigntParamFile);

            % multiregressor selection
            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).regress = ...
                struct('name', {}, 'val', {});

            % multicondition selection
            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).cond = ...
                struct('name', {}, 'onset', {}, 'duration', {});

            % The following lines are commented out because those parameters
            % can be set in the spm_my_defaults.m
            %  matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;

            sesCounter = sesCounter + 1;

        end
    end

end

function fullpathBoldFileName = getFunctionalFiles(varargin)

    [BIDS, opt, subID, funcFWHM, iSes, iRun] =  deal(varargin{:});

    % get the filename for this bold run for this task
    % and check that the file with the right prefix exist

    sessions = getInfo(BIDS, subID, opt, 'Sessions');

    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    prefix = getPrefix('FFX', opt, funcFWHM);
    if strcmp(opt.space, 'T1w')
        prefix = getPrefix('FFX_space-T1w', opt, funcFWHM);
    end

    [fileName, subFuncDataDir] = getBoldFilename( ...
        BIDS, ...
        subID, sessions{iSes}, runs{iRun}, opt);

    fullpathBoldFileName = inputFileValidation( ...
        subFuncDataDir, ...
        prefix, ...
        fileName);

    disp(fullpathBoldFileName);

end

function fullpathOnsetFileName = createAndReturnOnsetFile(opt, fullpathBoldFileName, isMVPA)

    % convert the tsv files to a mat file to be used by SPM
    % then point the batch to that newly created mat file with the
    % onsets

    [funcDataDir, boldFileName] = spm_fileparts(fullpathBoldFileName);

    tsvFile = fullfile( ...
        funcDataDir, ...
        strrep(boldFileName, '_bold.nii', '_events.tsv'));

    fullpathOnsetFileName = convertOnsetTsvToMat(tsvFile, opt, isMVPA);

end

function realigntParamFile = getRealignParamFile(opt, funcFWHM, fullpathBoldFileName)

    [~, motionRegressorPrefix] = getPrefix('FFX', opt, funcFWHM);

    [funcDataDir, boldFileName] = spm_fileparts(fullpathBoldFileName);

    realigntParamFile = ...
        fullfile(funcDataDir, ...
        ['rp_', motionRegressorPrefix, strrep(boldFileName, '.nii', '.txt')]);
end

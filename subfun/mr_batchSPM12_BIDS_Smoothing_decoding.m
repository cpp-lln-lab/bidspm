function mr_batchSPM12_BIDS_Smoothing_decoding(mm_smoothing,opt)
% This scripts performs smoothing to the functional data using a full width
% half maximum smoothing kernel of size "mm_smoothing".


% if input has no opt, load the opt.mat file
if nargin<2
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% Get current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% creates prefix to look for
if isfield(opt, 'numDummies') && opt.numDummies>0
    prefix = opt.dummy_prefix;
else
    prefix = '';
end

% Check the slice timing information is not in the metadata and not added
% manually in the opt variable.
if (isfield(opt.metadata, 'SliceTiming') && ~isempty(opt.metadata.SliceTiming)) ||  ~isempty(opt.sliceOrder)
    prefix = [opt.norm_prefix opt.STC_prefix prefix];
else
    prefix = opt.norm_prefix;
end


%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)              % For each group
    groupName = group(iGroup).name ;     % Get the Group name

    for iSub = 1:group(iGroup).numSub    % For each subject in the group
        subNumber = group(iGroup).subNumber{iSub}; % Get the Subject ID
        fprintf(1,'PREPARING: SMOOTHING JOB \n')

        ses_counter = 1;                 % file/loop counter

        % identify sessions for this subject
        [sessions, numSessions] = get_sessions(BIDS, subNumber, opt);

        % clear previous matlabbatch and files
        matlabbatch = [];
        allfiles=[];

        for iSes = 1:numSessions        % For each session

            % get all runs for that subject across all sessions
            [runs, numRuns] = get_runs(BIDS, subNumber, sessions{iSes}, opt);

            %numRuns = group(iGroup).numRuns(iSub);
            for iRun = 1:numRuns                     % For each run
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s SESSION: %i RUN:  %i \n',groupName,iSub,subNumber,iSes,iRun)

                % get the filename for this bold run for this task
                fileName = get_filename(BIDS, subNumber, ...
                    sessions{iSes}, runs{iRun}, 'bold', opt);

                % get fullpath of the file
                fileName = fileName{1};
                [subFuncDataDir, file, ext] = spm_fileparts(fileName);
                % get filename of the orginal file (drop the gunzip extension)
                if strcmp(ext, '.gz')
                    fileName = file;
                elseif strcmp(ext, '.nii')
                    fileName = [file ext];
                end

                files{1,1} = spm_select('FPList', subFuncDataDir, ['^' prefix fileName '$']);

                % add the files to list
                allfilestemp = cellstr(files);
                allfiles = [allfiles; allfilestemp];
                ses_counter = ses_counter + 1;

            end
        end

    matlabbatch{1}.spm.spatial.smooth.data=  allfiles;
    % Define the amount of smoothing required
    matlabbatch{1}.spm.spatial.smooth.fwhm = [mm_smoothing mm_smoothing mm_smoothing];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = ['s',num2str(mm_smoothing)];  % Prefix = s+NumberOfSmoothing

    %% SAVE THE MATLABBATCH
    %Create the JOBS directory if it doesnt exist
    JOBS_dir = fullfile(opt.derivativesDir, opt.JOBS_dir, subNumber);
    [~, ~, ~] = mkdir(JOBS_dir);

    save(fullfile(JOBS_dir, 'jobs_Smoothing_matlabbatch_SPM12.mat'), 'matlabbatch') % save the matlabbatch
    spm_jobman('run',matlabbatch)

    cd(WD);
    end
end


end

function mr_batchSPM12_BIDS_STC_decoding(opt)
% Performs SLICE TIMING CORRECTION of the functional data. The
% script for each subject and can handle multiple sessions and multiple
% runs.
% In the case the slice timing information wasn't sepcified in the json FILES
% in the BIDS data set (e.g it couldnt be extracted from the trento old scanner),
% then add this information manually in opt.sliceOrder field.
% If this is empty the slice timing correction will not be performed
% See Instruction.md for more information about slice timing correction
%
% INPUT:
% opt - options structure defined by the getOption function. If no inout is given
% this function will attempt to load a opt.mat file in the same directory
% to try to get some options

% if input has no opt, load the opt.mat file
if nargin<1
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

fprintf(1,'DOING SLICE TIME CORRECTION\n')

% IF slice timing is not in the metadata
if ~isfield(opt.metadata, 'SliceTiming') || isempty(opt.metadata.SliceTiming)
    fprintf(1,' SLICE TIMING INFORMATION COULD NOT BE EXTRACTED FROM METADATA.\n')
    fprintf(1,' CHECKING IF SPECIFIED IN opt IN THE "getOption" FUNCTION.\n\n')

    % IF SLICE TIME information is not in the metadata, you have the option
    % to add the slice order manually in the "opt" in the "getOptions"
    % function
    if ~isempty(opt.sliceOrder)
        sliceOrder = opt.sliceOrder  ;
        fprintf(' SLICE TIMING INFORMATION EXTRACTED FROM OPTIONS.\n')
    else
        fprintf(1, ' SLICE TIMING INFORMATION COULD NOT BE EXTRACTED.\n')
        warning('SKIPPING SLICE TIME CORRECTION: no slice timing specified.')
        return
    end
else % Otherwise get the slice order from the metadata
    sliceOrder = opt.metadata.SliceTiming;
    fprintf(' SLICE TIMING INFORMATION EXTRACTED.\n')
end

% prefix of the files to look for
if isfield(opt, 'numDummies') && opt.numDummies>0
    prefix = opt.dummy_prefix;
else
    prefix = '';
end

% get metadata for STC
% Note  that  slice  ordering is assumed to be from foot to head. If it is not, enter
% instead: TR - INTRASCAN_TIME - SLICE_TIMING_VECTOR

% SPM accepts slice time acquisition as inputs for slice order (simplifies
% things when dealing with multiecho data)
numSlices = length(sliceOrder);
TR = opt.metadata.RepetitionTime;
TA = TR - (TR/numSlices);

maxSliceTime = max(sliceOrder);
minSliceTime = min(sliceOrder);
if isempty(opt.STC_referenceSlice)
    referenceSlice = (maxSliceTime - minSliceTime)/2;
else
    referenceSlice = opt.STC_referenceSlice;
end
if referenceSlice > TA
    error('%s (%f) %s (%f).\n%s', ...
        'The reference slice time', referenceSlice, ...
        'is greater than the acquisition time', TA, ...
        'Reference slice time must be in milliseconds or leave it empty to use mid-acquisition time as reference.')
end

% clear/initiate matlabbatch
matlabbatch = [];

%% Loop through the groups, subjects, and sessions
% For each group

for iGroup= 1:length(group)
    groupName = group(iGroup).name ;     % Get the group name

    for iSub = 1:group(iGroup).numSub    % For each subject in the group

        % Get the ID of the subject
        %(i.e SubNumber doesnt have to match the iSub if one subject is exluded for any reason)
        subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID
        fprintf(1,' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',groupName,iSub,subNumber)

        %% GET FUNCTIOVAL FILES
        fprintf(1,' BUILDING STC JOB : STC\n')

        [sessions, numSessions] = get_sessions(BIDS, subNumber, opt);

        for iSes = 1:numSessions    % for each session

            % get all runs for that subject across all sessions
            [runs, numRuns] = get_runs(BIDS, subNumber, sessions{iSes}, opt);


            for iRun = 1:numRuns                    % For each Run

                % get the filename for this bold run for this task
                    fileName = get_filename(BIDS, subNumber, ...
                        sessions{iSes}, runs{iRun}, 'bold', opt);

                % get fullpath of the file
                fileName = fileName{1};
                [SubFuncDataDir, file, ext] = spm_fileparts(fileName);
                % get filename of the orginal file (drop the gunzip extension)
                if strcmp(ext, '.gz')
                    fileName = file;
                elseif strcmp(ext, '.nii')
                    fileName = [file ext];
                end

                files{1,1} = spm_select('FPList', SubFuncDataDir, ['^' prefix fileName '$']);
                % if this comes out empty we throw an error so we don't
                % have to wait for SPM to crash when running.
                if isempty(files)
                   error('Cannot find the file %s', ['^' prefix fileName '[.gz]$'])
                end

                % add the file to the list
                matlabbatch{1}.spm.temporal.st.scans{iRun} =  cellstr(files);

                % print out to screen files to process
                disp(files{1})

            end

        end

        matlabbatch{1}.spm.temporal.st.nslices = numSlices;              % Number of Slices
        matlabbatch{1}.spm.temporal.st.tr = TR;                          % Repetition Time
        matlabbatch{1}.spm.temporal.st.ta = TA;
        matlabbatch{1}.spm.temporal.st.so = sliceOrder;
        matlabbatch{1}.spm.temporal.st.refslice = referenceSlice;
        matlabbatch{1}.spm.temporal.st.prefix = opt.STC_prefix;

        %% SAVE THE MATLABBATCH
        %Create the JOBS directory if it doesnt exist
        JOBS_dir = fullfile(opt.JOBS_dir,subNumber);
        [~, ~, ~] = mkdir(JOBS_dir);

        save(fullfile(JOBS_dir, 'jobs_STC_matlabbatch.mat'), 'matlabbatch') % save the matlabbatch
       spm_jobman('run',matlabbatch)

    end
end

cd(WD);

end

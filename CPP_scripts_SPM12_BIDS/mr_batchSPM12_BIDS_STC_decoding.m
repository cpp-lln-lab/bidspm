function mr_batchSPM12_BIDS_STC_decoding(opt)
%% The script performs SLICE TIMING CORRECTION of the functional data. The
% script for each subject and can handle multiple sessions and multiple
% runs.

% For extracting the number of slices, the script should extract the information
%from the json file by getting the length of the vector of the slice timing
% nslices = length(j.SliceTiming);     <---- THE BEST WAY   (LINE 60)
% In the case the slice timing information wasnt in the json file (e.g it couldnt
% extract it from the trento old scanner), then add this information
% manually in the task json file in the derivatives directory by adding the
% field NumSlices.  e.g: "NumSlices":"39"

%% Reference Slice and Slice Order:
% If the acquisition was interleaved, then:
% REFERENCE SLICE is "2" [No matter how many slices the acquistions were]. ---> (LINE 63)
% Slice order: [1:2:nslices 2:2:nslices]   if interleaved ascending        ---> (LINE 113)

% If the acquisition was continous, then: the referenceSlice is "%ceil(nslices/2)"  ---> (LINE 63)
%REFERENCE SLICE is "%ceil(nslices/2)"
% Slice order [1:nslices]  --->(LINE 113)

%%
%%%%%%%BELOW: some comments from http://mindhive.mit.edu/node/109 on STC,
%%%%%%%when it should be applied....
% 7. At what point in the processing stream should you use it?
%
% This is the great open question about slice timing, and it's not super-answerable.
% Both SPM and AFNI recommend you do it before doing realignment/motion correction,
% but it's not entirely clear why. The issue is this:
%
% If you do slice timing correction before realignment, you might look down
% your non-realigned timecourse for a given voxel on the border of gray matter and CSF,
% say, and see one TR where the head moved and the voxel sampled from CSF
% instead of gray. This would results in an interpolation error for that voxel,
% as it would attempt to interpolate part of that big giant signal into the
% previous voxel.
% On the other hand, if you do realignment before slice timing correction,
% you might shift a voxel or a set of voxels onto a different slice, and
% then you'd apply the wrong amount of slice timing correction to them when
% you corrected - you'd be shifting the signal as if it had come from
% slice 20, say, when it actually came from slice 19, and shouldn't be shifted as much.
%
% There's no way to avoid all the error (short of doing a four-dimensional
% realignment process combining spatial and temporal correction - possibly
% coming soon), but I believe the current thinking is that doing slice
% timing first minimizes your possible error.
% The set of voxels subject to such an interpolation error is small, and
% the interpolation into another TR will also be small and will only affect
% a few TRs in the timecourse. By contrast, if one realigns first,
% many voxels in a slice could be affected at once,
% and their whole timecourses will be affected. I think that's why it
% makes sense to do slice timing first. That said, here's some articles
% from the SPM e-mail list that comment helpfully on this subject both ways,
% and there are even more if you do a search for
% "slice timing AND before" in the archives of the list.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% only run STC if we have a slice timing in metadata
if isfield(opt.metadata, 'SliceTiming')
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
    sliceOrder = opt.metadata.SliceTiming;
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
            % STC
            fprintf(1,' BUILDING STC JOB : STC\n')
            
            % get all runs for that subject across all sessions
            runs = spm_BIDS(BIDS, 'runs', 'sub', subNumber, 'task', opt.taskName);
            numRuns = size(runs,2);     % Get the number of runs
            
            for iRun = 1:numRuns                    % For each Run
                
                % get the filename for this bold run for this task
                fileName = spm_BIDS(BIDS, 'data', ...
                    'sub', subNumber, ...
                    'run', runs{iRun}, ...
                    'task', opt.taskName, ...
                    'type', 'bold');
                
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
                % If more than 1 run, get the functional files that contain the run number in the name
                if numRuns==1
                    files{1,1} = fullfile(SubFuncDataDir,...
                        ['dr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.nii']);
                elseif numRuns >1
                    files{1,1} = fullfile(SubFuncDataDir,...
                        ['dr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.nii']);
                end

                % add the file to the list
                matlabbatch{1}.spm.temporal.st.scans{iRun} =  cellstr(files);
                
                
            end

            matlabbatch{1}.spm.temporal.st.nslices = numSlices;              % Number of Slices
            matlabbatch{1}.spm.temporal.st.tr = TR;                        % Repetition Time
            matlabbatch{1}.spm.temporal.st.ta = TA;
            matlabbatch{1}.spm.temporal.st.so = sliceOrder; % Sequencial ascending / #Sequential descending: [nslices:-1:1] / Interleaved bottom>up: [1:2:nslices 2:2:nslices]
            matlabbatch{1}.spm.temporal.st.refslice = referenceSlice; % middle acquired slice (NOTE: Middle in time of acquisition, not space)
            matlabbatch{1}.spm.temporal.st.prefix = opt.STC_prefix;
            
            %% SAVE THE MATLABBATCH
            %Create the JOBS directory if it doesnt exist
            JOBS_dir = fullfile(SubFuncDataDir, opt.JOBS_dir);
            if ~exist(JOBS_dir,'dir')
                mkdir(JOBS_dir)
            end

            save(fullfile(JOBS_dir, 'jobs_STC_matlabbatch.mat'), 'matlabbatch') % save the matlabbatch
            spm_jobman('run',matlabbatch)
            
        end
    end
    
    cd(WD);
    
end

end


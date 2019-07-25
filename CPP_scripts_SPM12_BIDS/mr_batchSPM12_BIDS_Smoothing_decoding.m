function mr_batchSPM12_BIDS_Smoothing_decoding(mm_smoothing)
% This scripts performs smoothing to the functional data using a full width
% half maximum smoothing kernel of size "mm_smoothing".

WD = pwd;

% load the subjects/Groups information and the task name
[derivativesDir,taskName,group] = getData();

% output directory for the saved jobs
JOBS_dir = fullfile(derivativesDir,'JOBS',taskName);

matlabbatch = [];

allfiles=[];

%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)              % For each group
    groupName = group(iGroup).name ;     % Get the Group name
    
    for iSub = 1:group(iGroup).numSub    % For each subject in the group
        SubNumber = group(iGroup).SubNumber(iSub) ; % Get the Subject ID
        fprintf(1,'PREPARING: SMOOTHING JOB \n')
        
        ses_counter = 1;                 % file/loop counter
        
        % Get the number of sessions for that subject
        numSessions = group(iGroup).numSess(iSub) ;
        for ises = 1:numSessions        % For each session
            
            % Directory of the functional data
            SubFuncDataDir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',ises)],'func');
            cd(SubFuncDataDir)
            
            % Get the number of runs in that session for that subject
            numRuns = group(iGroup).numRuns(iSub);
            for iRun = 1:numRuns                     % For each run
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i SESSION: %i RUN:  %i \n',groupName,iSub,SubNumber,ises,iRun)
                
                % If there is 1 run, get the functional files (note that the name does not contain -run-01)
                % If more than 1 run, get the functional files that contain the run number in the name
                if numRuns==1
                    files{1,1} = fullfile(SubFuncDataDir,...
                        ['wadr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.nii']);
                elseif numRuns >1
                    files{1,1} = fullfile(SubFuncDataDir,...
                        ['wadr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.nii']);
                end
                
                % add the files to list
                allfilestemp = cellstr(files);
                allfiles = [allfiles; allfilestemp];
                ses_counter = ses_counter + 1;
                
            end
        end
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
if ~exist(JOBS_dir,'dir')
    mkdir(strdir)
end
cd(JOBS_dir)
eval (['save jobs_Smoothing_matlabbatch'])
spm_jobman('run',matlabbatch)

cd(WD);

end
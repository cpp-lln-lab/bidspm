function mr_removeDummies()
% This scripts removes the initial dummy scans at the beginning of the
% acquisition to allow for the homogenization of the magnetic field. The
% script will take the 4D functional nifti images and remove the first
% N-volumes. The dummmies will be saved in a dummies folder and the new 4D
% images will be saved with a prefix of 'dr_' --> Dummies Removed

% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[derivativesDir,taskName,group] = getData();

% Specify the number of dummies that you want to be removed.
numDummies = 4;

%% Loop through the groups, subjects, sessions
for iGroup= 1:length(group)             % For each group
    groupName = group(iGroup).name ;    % Get the group name
    
    for iSub = 1:group(iGroup).numSub   % For each Subject in the group
        SubNumber = group(iGroup).SubNumber(iSub) ; % Get the subject ID
        
        % Number of sessions for each subject
        numSessions = group(iGroup).numSess(iSub);
        
        for ises = 1:numSessions % For each session
            
            numRuns = group(iGroup).numRuns(iSub);     % Get the number of runs
            for iRun = 1:numRuns                       % For each Run
                
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i RUN: %i \n',groupName,iSub,SubNumber,iRun)
                
                % Go the functional data directory
                cd(fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',ises)],'func'))
                
                % If there is 1 run, get the functional files (note that the name does not contain -run-01)
                % If more than 1 run, get the functional files that contain the run number in the name
                if numRuns==1
                    fileName = ['sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.nii.gz'];
                elseif numRuns >1
                    fileName = ['sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.nii.gz'];
                end
                
                % load the functional image
                n=load_untouch_nii(fileName);
                
                % Create a dummies folder if it doesnt exist
                dummiesOuputDir = fullfile(pwd,'dummies');
                if ~exist(dummiesOuputDir,'dir')
                    mkdir(dummiesOuputDir)
                end
                
                %% Create the dummies 4D files and save it
                n_dummies = n ;
                n_dummies.img = n_dummies.img(:,:,:,1:numDummies);
                n_dummies.hdr.dime.dim(5) = size(n_dummies.img,4);  % Change the dimension in the header
                save_untouch_nii(n_dummies,fullfile(dummiesOuputDir,['dummies_',fileName]) )
                
                % Create the 4D functional files without the dummies and
                % save them
                n_noDummies = n;
                n_noDummies.img = n_noDummies.img(:,:,:,numDummies+1:end);
                n_noDummies.hdr.dime.dim(5) = size(n_noDummies.img,4);   % Change the dimension in the header
                save_untouch_nii(n_noDummies,['dr_',fileName(1:end-3)])  % dr : dummies removed
                
            end
        end
    end
end

cd(WD)

end

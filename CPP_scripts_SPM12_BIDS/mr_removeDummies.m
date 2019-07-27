function mr_removeDummies(opt)
% This scripts removes the initial dummy scans at the beginning of the
% acquisition to allow for the homogenization of the magnetic field. The
% script will take the 4D functional nifti images and remove the first
% N-volumes. The dummmies will be saved in a dummies folder and the new 4D
% images will be saved with a prefix of 'dr_' --> Dummies Removed

% TO DO
% - add a check to make sure that dummies are not removed AGAIN if this has
% already been done
% - can we find a way to run even if no dummy number was specified to at
% least unzip the data ???

% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

if isfield(opt, 'numDummies')
    
    numDummies = opt.numDummies;
    
    if numDummies<=0 || isempty(numDummies) % only run if a non null number of dummies is specified
        return
    else
        
        fprintf(1,'REMOVING DUMMIES\n')
        
        %% Loop through the groups, subjects, sessions
        for iGroup= 1:length(group)             % For each group
            groupName = group(iGroup).name ;    % Get the group name
            
            for iSub = 1:group(iGroup).numSub   % For each Subject in the group
                subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID
                
                % get all runs for that subject across all sessions
                runs = spm_BIDS(BIDS, 'runs', 'sub', subNumber, 'task', opt.taskName);
                numRuns = size(runs,2);     % Get the number of runs
                
                for iRun = 1:numRuns                       % For each Run
                    
                    fprintf(1,' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s RUN: %i \n',...
                        groupName,iSub,subNumber,iRun)
                    
                    % get the filename for this bold run for this task
                    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subNumber, ...
                        'run', runs{iRun}, ...
                        'task', opt.taskName, ...
                        'type', 'bold');
                    
                    % get fullpath of the file
                    fileName = fileName{1};
                    [path, file, ext] = spm_fileparts(fileName);
                    fileName = [file ext];
                    
                    % Go the functional data directory
                    cd(path)
                    
                    % load the functional image
                    n=load_untouch_nii(fileName);
                    
                    % Create a dummies folder if it doesnt exist
                    dummiesOuputDir = fullfile(path,'dummies');
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
                    save_untouch_nii(n_noDummies,[opt.dummy_prefix,fileName(1:end-3)])  % dr : dummies removed
                    
                end
            end
        end
        
        cd(WD)
        
    end
    
end

end

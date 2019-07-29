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


% if input has no opt, load the opt.mat file
if nargin<1
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

fprintf(1,'REMOVING DUMMIES\n')

if isfield(opt, 'numDummies')

    numDummies = opt.numDummies; % Number of dummies

    %% Loop through the groups, subjects, sessions
    for iGroup= 1:length(group)             % For each group
        groupName = group(iGroup).name ;    % Get the group name

        for iSub = 1:group(iGroup).numSub   % For each Subject in the group
            subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID

            sessions = spm_BIDS(BIDS, 'sessions', ...
                'sub', subNumber, ...
                'task', opt.taskName);
            numSessions = size(sessions,2);
            if numSessions==0
                numSessions = 1;
                sessions = {''};
            end

            for iSes = 1:numSessions    % for each session

                % get all runs for that subject across all sessions
                runs = spm_BIDS(BIDS, 'runs', ...
                    'sub', subNumber, ...
                    'task', opt.taskName, ...
                    'ses', sessions{iSes}, ...
                    'type', 'bold');
                numRuns = size(runs,2);     % Get the number of runs

                for iRun = 1:numRuns                       % For each Run

                    fprintf(1,' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s RUN: %i \n',...
                        groupName,iSub,subNumber,iRun)

                    % get the filename for this bold run for this task
                    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subNumber, ...
                        'run', runs{iRun}, ...
                        'ses', sessions{iSes}, ...
                        'task', opt.taskName, ...
                        'type', 'bold');

                    disp(fileName)

                    % get fullpath of the file
                    fileName = fileName{1};
                    [path, file, ext] = spm_fileparts(fileName);
                    fileName = [file ext];

                    % Go the functional data directory
                    cd(path)

                    % load the functional image
                    n=load_untouch_nii(fileName);

                    if numDummies<=0 || isempty(numDummies) % If no dummies
                        save_untouch_nii(n,[opt.dummy_prefix,fileName(1:end-3)]) % Save the functional data as unzipped nii
                    else
                        % Create a dummies folder if it doesnt exist
                        dummiesOuputDir = fullfile(path,'dummies');
                        [~, ~, ~] =  mkdir(dummiesOuputDir);

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
        end
    end

    cd(WD)
else
    error('Number of dummies is not specified!!')
end
end

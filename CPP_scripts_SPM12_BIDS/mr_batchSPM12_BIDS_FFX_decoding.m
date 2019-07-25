function mr_batchSPM12_BIDS_FFX_decoding(action,degreeOfSmoothing)
% This scripts builds up the design matrix for each subject.
% It has to be run in 2 separate steps (action) :
% case 1 = fMRI design and estimate
% case 2 = contrasts
% Adjust your contrasts as a subfunction at the end of the script

% degreeOfSmoothing is the number of the mm smoothing used in the
% normalized functional files. for unsmoothied data  degreeOfSmoothing = 0
% for smoothed data = ... mm
% in this way we can make multiple ffx for different smoothing degrees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check which level of smoothing is applied
if degreeOfSmoothing ==0       % If no smoothing applied
    smoothOrNonSmooth = 'w';   % Take the normalized data
elseif degreeOfSmoothing > 0   % If the smoothing is applied
    smoothOrNonSmooth = ['s',num2str(degreeOfSmoothing),'w']; % Take the smoothed files
elseif degreeOfSmoothing == -1 % If native space used
    smoothOrNonSmooth = 'r';   % Take the resliced non-smoothed native space images.
end

% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[derivativesDir,taskName,group] = getData();

%% load the json file to extract acquisition parameters
cd (derivativesDir)
json_file = ['task-',taskName,'_bold.json'];
j = spm_jsonread(json_file);
TR = j.RepetitionTime ; %2.2;

%%
matlabbatch = [];

switch action
    case 1 % fMRI design and estimate
        tic
        
        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)              % For each group
            groupName = group(iGroup).name ;     % Get the Group name
            
            for iSub = 1:group(iGroup).numSub    % For each Subject in the group
                SubNumber = group(iGroup).SubNumber(iSub) ;   % Get the Subject ID
                
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                
                files = [] ;
                condfiles = [];
                matlabbatch = [];
                matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
                matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR ;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
                
                % The Directory to save the FFX files (Create it if it doesnt exist)
                ffx_dir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',1)],...
                    ['ffx_',taskName],['ffx_',num2str(degreeOfSmoothing),'/']);%% change according to files
                if ~exist(ffx_dir,'dir')
                    mkdir(ffx_dir)
                else % If it exists, issue a warning that it has been overwritten
                    fprintf(1,'A DIRECTORY WITH THIS NAME ALREADY EXISTED AND WAS OVERWRITTEN, SORRY \n');
                    rmdir(ffx_dir,'s')
                    mkdir(ffx_dir)
                end
                matlabbatch{1}.spm.stats.fmri_spec.dir = {ffx_dir};
                % FMRI DESIGN
                fprintf(1,'BUILDING JOB : FMRI design\n')
                
                %
                ses_counter = 1;
                % Get the number of sessions for that subject in that group
                numSessions = group(iGroup).numSess(iSub);
                for ises = 1:numSessions                        % For each session
                    
                    % Functional data directory
                    SubFuncDataDir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',ises)],'func');
                    cd(SubFuncDataDir)
                    
                    % Get the number of runs in that session for that subject in that group
                    numRuns = group(iGroup).numRuns(iSub);
                    for iRun = 1:numRuns                        % For each run
                        
                        fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i SESSION: %i RUN:  %i \n',groupName,iSub,SubNumber,ises,iRun)
                        
                        % If there is 1 run, get the functional files (note that the name does not contain -run-01)
                        % If more than 1 run, get the functional files that contain the run number in the name
                        if numRuns==1
                            files{ses_counter,1} = fullfile(SubFuncDataDir,...    % functional files
                                [smoothOrNonSmooth,'adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.nii']);
                            % tsv file
                            tsv_file{ses_counter,1} = ['Onset_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_events.tsv'];
                            rp_file{ses_counter,1} = fullfile(SubFuncDataDir,...
                                ['rp_','adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.txt']);
                        elseif numRuns >1
                            files{1,1} = fullfile(SubFuncDataDir,...     % functional files
                                [smoothOrNonSmooth,'adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.nii']);
                            % tsv file
                            tsv_file{ses_counter,1} = ['Onset_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_events.tsv'];
                            rp_file{ses_counter,1} = fullfile(SubFuncDataDir,...
                                ['rp_','adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.txt']);
                            
                        end
                        
                        % Convert the tsv files to a mat file to be used by SPM
                        convert_tsv2mat(tsv_file{ses_counter,1},TR)
                        
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).scans = cellstr(files);
                        
                        condfiles = fullfile(pwd,['Onsets_',tsv_file{ses_counter,1}(1:end-4),'.mat']);
                        % multicondition selection
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).cond = struct('name', {}, 'onset', {}, 'duration', {});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).multi = cellstr(condfiles(:,:));
                        % multiregressor selection
                        %rpfile  = spm_select('List',SubFuncDataDir,char(strcat('^rp_adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.txt$')));
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).regress = struct('name', {}, 'val', {});
                        %matlabbatch{1}.spm.stats.fmri_spec.sess(ises).multi_reg = cellstr(fullfile(SubFuncDataDir,rpfile));
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).multi_reg = cellstr(rp_file{ses_counter,1});
                        % HPF
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;
                        
                        ses_counter  =ses_counter +1;
                    end
                end
                
                matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
                matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
                matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
                matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
                matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
                
                
                % FMRI ESTIMATE
                fprintf(1,'BUILDING JOB : FMRI estimate\n')
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
                matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                
                
                cd(ffx_dir)
                save (['jobs_ffx_',num2str(degreeOfSmoothing),'_',taskName],'matlabbatch')
                spm_jobman('run',matlabbatch)
                
                cd(WD);
            end
        end
        
        
    case 2  % CONTRASTS
        tic
        
        fprintf(1,'BUILDING JOB : FMRI contrasts\n')
        
        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)                     % For each group
            groupName = group(iGroup).name ;            % Get the group name
            for iSub = 1:group(iGroup).numSub           % For each subject in the group
                
                SubNumber = group(iGroup).SubNumber(iSub) ;  % Get the Subject ID
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                
                % ffx folder
                ffx_dir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',1)],...
                    ['ffx_',taskName],['ffx_',num2str(degreeOfSmoothing),'/']);         %% change according to files
                [C, contrastes] = pm_con(ffx_dir,taskName);                             % create contrasts
                
                cd(ffx_dir)
                load(['jobs_ffx_',num2str(degreeOfSmoothing),'_',taskName,'.mat'])   % Loading the ss's job to append the contrasts
                
                matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(ffx_dir,'SPM.mat'));
                
                for icon = 1:size(contrastes,2)
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.name = contrastes(icon).name;
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.convec = contrastes(icon).C;
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
                end
                
                matlabbatch{3}.spm.stats.con.delete = 1;
                
                save(['jobs_ffx_',num2str(degreeOfSmoothing),'_',taskName,'.mat'],'matlabbatch')
                
                % Pruning the empty options
                for ii = 1:2
                    matlabbatch(1) = []; % no curly brackets to remove array
                end
                
                spm_jobman('run',matlabbatch)
                toc
            end
            cd(WD)
        end % switch
end

cd(WD);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [C, contrastes] = pm_con(ffx_folder,taskName)
% To know the names of the columns of the design matrix, type :
% strvcat(SPM.xX.name)
%
% EXAMPLE
% Sn(1) ins 1
% Sn(1) ins 2
% Sn(1) T1
% Sn(1) T2
% Sn(1) R1
% Sn(1) R2
% Sn(1) R3
% Sn(1) R4
% Sn(1) R5
% Sn(1) R6

cd(ffx_folder);
load SPM


% C = zeros(18,size(SPM.xX.X,2));
contrastes = struct('C',[],'name',[]);
line_counter = 0;
C = [];


%% Visual
C = [C ;zeros(1,size(SPM.xX.X,2))]; % add 1 lign to C (more flexible than adding a fixed whole bunch at once)
for iContrast=1:size(SPM.xX.X,2)
    if findstr(SPM.xX.name{iContrast},'V_U*bf(1)')
        C(end,iContrast) = 1;
    end
end

line_counter = line_counter + 1;
contrastes(line_counter).C = C(end,:);
contrastes(line_counter).name =  'V_U';
%end


%%
C = [C ;zeros(1,size(SPM.xX.X,2))]; % add 1 lign to C (more flexible than adding a fixed whole bunch at once)
for iContrast=1:size(SPM.xX.X,2)
    if findstr(SPM.xX.name{iContrast},'V_D*bf(1)')
        C(end,iContrast) = 1;
    end
end

line_counter = line_counter + 1;
contrastes(line_counter).C = C(end,:);
contrastes(line_counter).name =  'V_D';
%end


%%
C = [C ;zeros(1,size(SPM.xX.X,2))]; % add 1 lign to C (more flexible than adding a fixed whole bunch at once)
for iContrast=1:size(SPM.xX.X,2)
    if findstr(SPM.xX.name{iContrast},'A_D*bf(1)')
        C(end,iContrast) = 1;
    end
end

line_counter = line_counter + 1;
contrastes(line_counter).C = C(end,:);
contrastes(line_counter).name =  'A_D';
%end

%%
C = [C ;zeros(1,size(SPM.xX.X,2))]; % add 1 lign to C (more flexible than adding a fixed whole bunch at once)

for iContrast=1:size(SPM.xX.X,2)
    if findstr(SPM.xX.name{iContrast},'V_D*bf(1)')
        C(end,iContrast) = 1;
    end
end

for iContrast=1:size(SPM.xX.X,2)
    if findstr(SPM.xX.name{iContrast},'A_D*bf(1)')
        C(end,iContrast) = -1;
    end
end

line_counter = line_counter + 1;
contrastes(line_counter).C = C(end,:);
contrastes(line_counter).name =  'V_D - A_D';
%end

%% Save the contrasts
save(['contrasts_ffx_',taskName,'.mat'],'contrastes')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function convert_tsv2mat(tsv_file,TR)
%% This function takes a tsv file and converts it to an onset file suitable for SPM ffx analysis
% The scripts extracts the conditions' names, onsets, and durations, and
% converts them to TRs (time unit) and saves the onset file to be used for
% SPM
%%

% Read the tsv file
t = tdfread(tsv_file,'tab');
fprintf('reading the tsv file : %s \n', tsv_file)
conds = t.condition;        % assign all the tsv information to a variable called conds.

names_tmp=cell(size(conds,1),1);
for iCond = 1:size(conds,1)                        % for each line in the tsv file
    names_tmp(iCond,1)= cellstr(conds(iCond,:));   % Get the name of the condition
end

% Get the unique names of the conditions (removing repeitions)
names = unique(names_tmp);
NumConditions =length(names);

% Create empty variables of onsets and durations
onsets = cell(1,NumConditions) ;
durations = cell(1,NumConditions) ;

% for each condition
for iCond = 1:NumConditions
    
    % Get the index of each condition by comparing the unique names and
    % each line in the tsv files
    idx(:,iCond) = find(strcmp(names(iCond),names_tmp)) ;
    onsets{1,iCond} = t.onset(idx(:,iCond))'./TR ;             % Get the onset and duration of each condition
    durations{1,iCond} = t.duration(idx(:,iCond))'./TR ;       % and divide them by the TR to get the time in TRs
    % rather than seconds
end

fprintf('TR : %.4f \n', TR)
fprintf('Onsets and durations divided by TR \n\n')

% save the onsets as a matfile
save(['Onsets_',tsv_file(1:end-4),'.mat'],'names','onsets','durations')


end

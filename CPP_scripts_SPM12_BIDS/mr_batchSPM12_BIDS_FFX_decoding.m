function mr_batchSPM12_BIDS_FFX_decoding(action,degreeOfSmoothing,opt)
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


% if input has no opt, load the opt.mat file
if nargin<3
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% Check which level of smoothing is applied
if degreeOfSmoothing ==0       % If no smoothing applied
    smoothingPrefix = '';   % Take the normalized data
elseif degreeOfSmoothing > 0   % If the smoothing is applied
    smoothingPrefix = ['s',num2str(degreeOfSmoothing)]; % Take the smoothed files
end

%%
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

% Prefix for motion regressor Parameters
MotionRegressorPrefix = [opt.STC_prefix prefix];

% Check the slice timing information is not in the metadata and not added
% manually in the opt variable.
if (isfield(opt.metadata, 'SliceTiming') && ~isempty(opt.metadata.SliceTiming)) || isfield(opt,'sliceOrder')
    prefix = [smoothingPrefix opt.norm_prefix opt.STC_prefix prefix];
end


% GET TR from metadata
TR = opt.metadata.RepetitionTime;

%%

switch action
    case 1 % fMRI design and estimate
        tic
        
        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)              % For each group
            groupName = group(iGroup).name ;     % Get the Group name
            
            for iSub = 1:group(iGroup).numSub    % For each Subject in the group
                
                files = [] ;
                condfiles = [];
                matlabbatch = [];
                
                subNumber = group(iGroup).subNumber{iSub} ;   % Get the Subject ID
                
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName,iSub,subNumber)
                
                matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
                matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR ;
                
                
                
                
                %%% THIS HAS TO BE CHANGED TO MATCH THE OPTION USED IN SLICE
                %%% TIMING !!!!!
                
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
                
                %%%
                %%%
                
                
                
                
                % The Directory to save the FFX files (Create it if it doesnt exist)
                ffx_dir = fullfile(opt.derivativesDir,...
                    ['sub-',subNumber],...
                    ['ses-01'],...
                    ['ffx_',opt.taskName],...
                    ['ffx_',num2str(degreeOfSmoothing)']);
                
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
                
                %%
                % identify sessions for this subject
                cd(WD);
                [sessions, numSessions] = get_sessions(BIDS, subNumber, opt);
                
                % clear previous matlabbatch and files
                %matlabbatch = [];
                %allfiles=[];
                %%
                for iSes = 1:numSessions                        % For each session
                    
                    % get all runs for that subject across all sessions
                    cd(WD);
                    [runs, numRuns] = get_runs(BIDS, subNumber, sessions{iSes}, opt);
                    
                    %numRuns = group(iGroup).numRuns(iSub);
                    for iRun = 1:numRuns                        % For each run
                        
                        fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s SESSION: %i RUN:  %i \n',groupName,iSub,subNumber,iSes,iRun)
                        
                        
                        % get the filename for this bold run for this task
                        cd(WD);
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
                        
                        tsv_file{ses_counter,1} = [fileName(1:end-9),'_events.tsv'];
                        rp_file{ses_counter,1} = ...
                            fullfile(subFuncDataDir, ...
                            ['rp_', MotionRegressorPrefix ,fileName(1:end-4),'.txt']);
                        
                        
                        cd(subFuncDataDir)
                        % Convert the tsv files to a mat file to be used by SPM
                        convert_tsv2mat(tsv_file{ses_counter,1},TR)
                        
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).scans = cellstr(files);
                        
                        condfiles = ...
                            fullfile(pwd,['Onsets_',tsv_file{ses_counter,1}(1:end-4),'.mat']);
                        
                        % multicondition selection
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).cond = ...
                            struct('name', {}, 'onset', {}, 'duration', {});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).multi = ...
                            cellstr(condfiles(:,:));
                        % multiregressor selection
                        %rpfile  = spm_select('List',SubFuncDataDir,char(strcat('^rp_adr_sub-',groupName,sprintf('%02d',SubNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.txt$')));
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).regress = ...
                            struct('name', {}, 'val', {});
                        %matlabbatch{1}.spm.stats.fmri_spec.sess(ises).multi_reg = ...cellstr(fullfile(SubFuncDataDir,rpfile));
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).multi_reg = ...
                            cellstr(rp_file{ses_counter,1});
                        
                        
                        % HPF - SHOULD BE SET IN OPTIONS!!!
                        matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;
                        
                        ses_counter = ses_counter +1;
                    end
                end
                
                matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
                
                %%% SHOULD BE SET IN OPTIONS
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
                
                
                matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
                matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
                matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
                
                %%% SHOULD BE SET IN OPTIONS
                matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
                
                
                % FMRI ESTIMATE
                fprintf(1,'BUILDING JOB : FMRI estimate\n')
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = ...
                    'fMRI model specification: SPM.mat File';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = ...
                    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = ...
                    substruct('.','spmmat');
                matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                
                
                %cd(ffx_dir)
                %Create the JOBS directory if it doesnt exist
                JOBS_dir = fullfile(opt.JOBS_dir,subNumber);
                [~, ~, ~] = mkdir(JOBS_dir);
                save(fullfile(JOBS_dir, ['jobs_ffx_',...
                    num2str(degreeOfSmoothing),'_',opt.taskName,'.mat']), ...
                    'matlabbatch')
                
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
                
                matlabbatch = [];
                subNumber = group(iGroup).subNumber{iSub} ;  % Get the Subject ID
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName,iSub,subNumber)
                
                JOBS_dir = fullfile(opt.JOBS_dir,subNumber);
                
                % identify sessions for this subject
                cd(WD);
                [sessions, numSessions] = get_sessions(BIDS, subNumber, opt);
                
                for iSes = 1
                    % get all runs for that subject across all sessions
                    [runs, numRuns] = get_runs(BIDS, subNumber, sessions{iSes}, opt);
                    for iRun = 1
                        % get the filename for this bold run for this task
                        fileName = get_filename(BIDS, subNumber, ...
                            sessions{iSes}, runs{iRun}, 'bold', opt);
                    end
                end
                % get fullpath of the file
                fileName = fileName{1};
                [subFuncDataDir, file, ext] = spm_fileparts(fileName);
                
                % ffx folder
                ffx_dir = fullfile(opt.derivativesDir,['sub-',subNumber],['ses-01'],['ffx_',opt.taskName],['ffx_',num2str(degreeOfSmoothing)']);
                
                cd(JOBS_dir)
                % Create Contrasts
                [C, contrastes] = pm_con(ffx_dir,opt.taskName,JOBS_dir);
                
                cd(JOBS_dir)
                load(['jobs_ffx_',num2str(degreeOfSmoothing),'_',opt.taskName,'.mat'])   % Loading the ss's job to append the contrasts
                
                matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(ffx_dir,'SPM.mat'));
                
                for icon = 1:size(contrastes,2)
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.name = contrastes(icon).name;
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.convec = contrastes(icon).C;
                    matlabbatch{3}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
                end
                
                matlabbatch{3}.spm.stats.con.delete = 1;
                
                % Pruning the empty options
                for ii = 1:2
                    matlabbatch(1) = []; % no curly brackets to remove array
                end
                
                % Save ffx matlabbatch in JOBS
                save(fullfile(JOBS_dir, ...
                    ['jobs_ffx_',...
                    num2str(degreeOfSmoothing),'_',opt.taskName,'_Contrasts.mat']), ...
                    'matlabbatch') % save the matlabbatch
                
                spm_jobman('run',matlabbatch)
                toc
            end
            cd(WD)
        end % switch
end

cd(WD);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [C, contrastes] = pm_con(ffx_folder,taskName,JOBS_dir)
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


% Save contrasts in JOBS directory
save(fullfile(JOBS_dir,['contrasts_ffx_',taskName,'.mat']),'contrastes')

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
names = unique(names_tmp)';
NumConditions =length(names);

% Create empty variables of onsets and durations
onsets = cell(1,NumConditions) ;
durations = cell(1,NumConditions) ;

% for each condition
for iCond = 1:NumConditions
    
    % Get the index of each condition by comparing the unique names and
    % each line in the tsv files
    idx{iCond,1} = find(strcmp(names(iCond),names_tmp)) ;
    onsets{1,iCond} = t.onset(idx{iCond,1})'./TR ;             % Get the onset and duration of each condition
    durations{1,iCond} = t.duration(idx{iCond,1})'./TR ;       % and divide them by the TR to get the time in TRs
    % rather than seconds
end

fprintf('TR : %.4f \n', TR)
fprintf('Onsets and durations divided by TR \n\n')

% save the onsets as a matfile
save(['Onsets_',tsv_file(1:end-4),'.mat'],'names','onsets','durations')


end

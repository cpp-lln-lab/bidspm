function make4Dmaps(degreeOfSmoothing, opt, deleteIndBeta, deleteIndTmaps, deleteResMaps)
% Make 4D images of beta and t-maps for the MVPA
% Inputs
% degreeOfSmoothing - smoothing (FWHM) applied to the the normalized EPI
%
% opt - options structure defined by the getOption function. If no inout is given
%   this function will attempt to load a opt.mat file in the same directory
%   to try to get some options
%
% deleteIndBeta, deleteIndTmaps, deleteResMaps: boolean to decide to delete
% original t-maps, beta-maps or ResMaps (default = true)


% if input has no opt, load the opt.mat file
if nargin<2
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% delete individual Beta and tmaps
if nargin <3            
    deleteIndBeta = 1;
    deleteIndTmaps = 1;
    deleteResMaps = 1;
end

% assign isMVPA to true
isMVPA = 1;         

% load the subjects/Groups information and the task name
[group, opt, ~] = getData(opt);

%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)              % For each group
    
    for iSub = 1:group(iGroup).numSub    % For each subject in the group
        
        subNumber = group(iGroup).subNumber{iSub}; % Get the Subject ID
        fprintf(1,'PREPARING: 4D maps: %s \n',subNumber)
        
        % clear previous matlabbatch and files
        matlabbatch = [];
        
        ffxDir = getFFXdir(subNumber, degreeOfSmoothing, opt, isMVPA);
        
        load(fullfile(ffxDir, 'SPM.mat'))
        
        contrasts = pmCon(ffxDir, opt.taskName, opt, isMVPA);
        
        beta_maps=cell(length(contrasts),1);
        t_maps = cell(length(contrasts),1);
        
        
        % path to beta and t-map files.
        for iContrast = 1:length(beta_maps)
            % Note that the betas are created from the idx (Beta_idx(iBeta))
            beta_maps{iContrast,1} = sprintf('beta_%04d.nii,1', find(contrasts(iContrast).C)) ;  
            % while the contrastes (t-maps) are not from the index. They were created
            t_maps{iContrast,1} = sprintf('spmT_%04d.nii,1', iContrast) ;               
        end
             
        spm('defaults','fmri');
        spm_jobman('initcfg');
        
        %% 4D beta maps
        matlabbatch{1}.spm.util.cat.vols = beta_maps ;
        matlabbatch{1}.spm.util.cat.name = ['4D_beta_', num2str(degreeOfSmoothing), '.nii'];
        matlabbatch{1}.spm.util.cat.dtype = 4;
        
        %% 4D t-maps
        matlabbatch{2}.spm.util.cat.vols = t_maps ;
        matlabbatch{2}.spm.util.cat.name = ['4D_t_maps_', num2str(degreeOfSmoothing), '.nii'];
        matlabbatch{2}.spm.util.cat.dtype = 4;
        
        spm_jobman('run',matlabbatch);
        
        % delete maps
        if deleteIndBeta
            
            % delete all individual beta maps
            fprintf('Deleting individual beta-maps ...  ')
            for iBeta= 1:length(SPM.Vbeta)
                delete(['beta_', sprintf('%04d',iBeta) ,'.nii'])
                
            end
            fprintf('Done. \n\n\n ')
            
        end
        
        if  deleteIndTmaps
            
            % delete all individual con maps (from 1 to length(idx))
            fprintf('Deleting individual con maps ...  ')
            for iCon= 1:length(contrasts)
                delete(['con_',sprintf('%04d',iCon) ,'.nii'])               
            end
            fprintf('Done. \n\n\n ')
            
            % delete all individual t-maps (from 1 to length(idx))
            fprintf('Deleting individual t-maps ...  ')
            for iTmap= 1:length(contrasts)
                delete(['spmT_',sprintf('%04d',iTmap) ,'.nii'])
            end
            fprintf('Done. \n\n\n ')
        end
        
        clear beta_maps
        clear t_maps
                
        if deleteResMaps
            % delete RS files
            ResFiles = dir('Res_*.nii');
            for iRes=1:length(ResFiles)
                delete(ResFiles(iRes).name)
            end
        end
        
        % delete mat files
        if exist(['4D_beta_', num2str(degreeOfSmoothing), '.mat'],'file')
            delete(['4D_beta_', num2str(degreeOfSmoothing), '.mat']);
        end
        if exist(['4D_t_maps_', num2str(degreeOfSmoothing), '.mat'],'file')
            delete(['4D_t_maps_', num2str(degreeOfSmoothing), '.mat']);
        end
        
        %% SAVE THE MATLABBATCH
        %Create the JOBS directory if it doesnt exist
        JOBS_dir = fullfile(opt.JOBS_dir, subNumber);
        [~, ~, ~] = mkdir(JOBS_dir);
        
        save(fullfile(JOBS_dir,'Contrasts_MVPA_SPM12.mat'),'contrasts');
        save(fullfile(JOBS_dir, 'jobs_matlabbatch_SPM12_create4Dmaps.mat'), 'matlabbatch') % save the matlabbatch
        
    end
end

end



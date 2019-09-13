function BIDS_RFX(action, mmFunctionalSmoothing, mmConSmoothing, opt)
% This script smooth all con images created at the fisrt level in each
% subject, create a mean structural image and mean mask over the
% population, process the factorial design specification  and estimation and estimate Contrats.
%
% INPUTS
% - action
%   - case 1 : smooth con images
%   - case 2 : Mean Struct, MeanMask, Factorial design specification and
%      estimation, Contrst estimation
%
% - mmFunctionalSmoothing = How much smoothing was applied to the functional
%    data in the preprocessing
% - mmConSmoothing = How much smoothing is required for the CON images for
%    the second level analysis
%
% Your input is twofold :
% 1. Specify your data at the beginning of the script
% 2. In the origdir, create a structure containing all possible contrasts,
% example: ConOfInterest.mat containing the structure Session.con (contrasts of interest by group)
% IMPORTANT: To create the structure, use the script "List_of_Contrast.m"
% The Contrast names should match those in the single level FFX and in THE
% SAME ORDER.

% if input has no opt, load the opt.mat file
if nargin<4
    load('opt.mat') 
    fprintf('opt.mat file loaded \n\n')
end

% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% JOBS Directory
JOBS_dir = fullfile(opt.JOBS_dir);

matlabbatch = [];

% Check which level of CON smoothing is desired
if mmConSmoothing==0
    smoothOrNonSmooth = '';
elseif mmConSmoothing > 0
    smoothOrNonSmooth = ['s',num2str(mmConSmoothing)];
else
    error ('Check you Con files')
end

% TASK NAME
ExperimentName = opt.taskName;

origdir = pwd;

switch action
    case 1 % Smooth all con images
        
        matlabbatch = {};
        
        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)
            
            groupName = group(iGroup).name ;    % Get the Group Name
            
            for iSub = 1:group(iGroup).numSub   % For each subject
                
                subNumber = group(iGroup).subNumber{iSub} ;   % Get the Subject ID
                
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName,iSub,subNumber)
                
                % FFX Directory
                ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt);
                conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
                matlabbatch{1}.spm.spatial.smooth.data = cellstr(conImg);
                
            end
        end
        
        % Define how much smoothing is required
        matlabbatch{1}.spm.spatial.smooth.fwhm = [mmConSmoothing mmConSmoothing mmConSmoothing];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = [...
            spm_get_defaults('smooth.prefix'), num2str(mmConSmoothing)];
        
        % save the matlabbatch
        save(fullfile(JOBS_dir, ...
            ['jobs_matlabbatch_SPM12_SmoothCon_',...
            num2str(mmConSmoothing),'_',...
            opt.taskName,'_Contrasts.mat']), ...
            'matlabbatch') % save the matlabbatch
        
        fprintf(1,'SMOOTHING CON IMAGES...')
        spm_jobman('run',matlabbatch)
        
    case 2
        
        matlabbatch = {};
        
        % Define the RFX folder name and create it in the derivatives
        % directory
        RFX_FolderName = fullfile(opt.derivativesDir,...
            ['RFX_',opt.taskName],...
            ['RFX_FunctSmooth',num2str(mmFunctionalSmoothing),...
            '_ConSmooth_',num2str(mmConSmoothing)]) ;
        
        [~,~,~] = mkdir(RFX_FolderName);
        
        % Create Mean Structural Image
        fprintf(1,'BUILDING JOB: Create Mean Structural Image...')
        
        subCounter = 0;
        
        for iGroup= 1:length(group)                    % For each group
            groupName = group(iGroup).name ;           % Get the group name
            
            for iSub = 1:group(iGroup).numSub          % For each subject
                
                subCounter = subCounter+1;
                
                subNumber = group(iGroup).subNumber{iSub} ;   % Get the Subject ID
                
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName, iSub, subNumber)
                
                
                %% STRUCTURAL
                struct = spm_BIDS(BIDS, 'data', ...
                    'sub', subNumber, ...
                    'type', 'T1w');
                % we assume that the first T1w is the correct one (could be an
                % issue for data set with more than one
                struct = struct{1};
                
                [subStrucDataDir, file, ext] = spm_fileparts(struct);
                
                % get filename of the orginal file (drop the gunzip extension)
                if strcmp(ext, '.gz')
                    fileName = file;
                elseif strcmp(ext, '.nii')
                    fileName = [file ext];
                end
                
                files = inputFileValidation(...
                    subStrucDataDir, ...
                    [spm_get_defaults('normalise.write.prefix'), ...
                    spm_get_defaults('deformations.modulate.prefix')], ...
                    fileName);
                
                matlabbatch{1}.spm.util.imcalc.input{subCounter,:} = files{1};
                
                
                %% Mask
                ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt);
                
                files = inputFileValidation(ffxDir, '', 'mask.nii');
                
                matlabbatch{2}.spm.util.imcalc.input{subCounter,:} = files{1};

            end
        end
        
        
        %% Generate the equation to get the mean of the mask and structural image
        % example : if we have 5 subjects, Average equation = '(i1+i2+i3+i4+i5)/5'
        tmpImg = [] ;
        numImg = subCounter ;
        imgNum  = 1:subCounter ;
        
        tmpImg=sprintf('+i%i',imgNum) ;
        tmpImg=tmpImg(2:end) ;
        
        sumEquation = ['(',tmpImg,')'] ;
        meanStruct_equation = ['(',tmpImg,')/',num2str(length(imgNum))] ;     % meanStruct_equation = '(i1+i2+i3+i4+i5)/5'
        meanMask_equation = strcat(sumEquation,'>0.75*',num2str(numImg))  ;     % meanMask_equation = '(i1+i2+i3+i4+i5)>0.75*5'
        
        %% The mean structural will be saved in the RFX folder
        matlabbatch{1}.spm.util.imcalc.output = 'MeanStruct.nii';
        matlabbatch{1}.spm.util.imcalc.outdir{:} = RFX_FolderName;
        matlabbatch{1}.spm.util.imcalc.expression = meanStruct_equation ;
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        
        
        %% The mean mask will be saved in the RFX folder
        matlabbatch{2}.spm.util.imcalc.output = 'MeanMask.nii';
        matlabbatch{2}.spm.util.imcalc.outdir{:} = RFX_FolderName;
        matlabbatch{2}.spm.util.imcalc.expression = meanMask_equation ;
        matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{2}.spm.util.imcalc.options.mask = 0;
        matlabbatch{2}.spm.util.imcalc.options.interp = 1;
        matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
        
        fprintf(1,'Create Mean Struct and Mask IMAGES...')

        % save the matlabbatch
        save(fullfile(JOBS_dir, ...
            'jobs_matlabbatch_SPM12_CreateMeanStrucMask.mat'), ...
            'matlabbatch') % save the matlabbatch
        
        spm_jobman('run',matlabbatch)
        
        
        %% Factorial design specification

        % Load the list of contrasts on interest for the RFX
        
        fprintf(1,'BUILDING JOB: Factorial Design Specification')
        cd(origdir)
        
        eval (['load ConOfInterest']) % In this mat file, there should be the contrasts of interests to analyze. They should match the name and order of those in the FFX folder.
        con = 0;
        
        matlabbatch = {};
        
        % For each contrast
        for j = 1:size(Session,2)
            
            range = {};
            con = con+1;
            
            %subCounter=0;
            % For each group
            for iGroup= 1:length(group)
                groupName = group(iGroup).name ;
                
                for iSub = 1:group(iGroup).numSub       % For each subject
                    subNumber = group(iGroup).subNumber{iSub} ;  % Get the subject ID
                    fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',...
                        groupName,iSub,subNumber)
                    
                    % FFX DIRECTORY
                    ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt);
                    
                    a = Session(j).con;
                    ConList = dir(sprintf([smoothOrNonSmooth,'con_%0.4d.nii'],con));
                    range{iGroup}.donnees{iSub,:} = fullfile([ffxDir, ConList.name]);
                    
                    
                end
                
                a = [];
                for i = 1:size(range{iGroup}.donnees,1)
                    a = [a;isempty(range{iGroup}.donnees{i})];
                end
                c = find(a==0);
                for pp = 1:size(c,1)
                    matlabbatch{j}.spm.stats.factorial_design.des.fd.icell(iGroup).levels = iGroup; %#ok<*AGROW>
                    matlabbatch{j}.spm.stats.factorial_design.des.fd.icell(iGroup).scans(pp,:) = {range{iGroup}.donnees{c(pp),:}}; % t1: One sample T Test - t2  Two sample T Test
                end
                
            end
            
            % GROUP and the number of levels in the group. if 2 groups ,
            % then number of levels = 2
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.name = 'GROUP';
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.levels = 1;
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.dept = 0;
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.variance = 1; % 1: Assumes that the variance is not the same across groups / 0= There is no difference in the variance between groups
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
            matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
            %matlabbatch{j}.spm.stats.factorial_design.cov = [];
            matlabbatch{j}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{j}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{j}.spm.stats.factorial_design.masking.em = {...
                fullfile(opt.derivativesDir,RFX_FolderName,'Meanmask.nii')};
            matlabbatch{j}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{j}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{j}.spm.stats.factorial_design.globalm.glonorm = 1;
            
            %% Linux does not support directory name '*' or ' ' that are replaced by
            %% 'x' or '' here
            if ~isempty(findstr('*',Session(j).con))
                Session(j).con(findstr('*',Session(j).con)) = 'x';
            end
            if ~isempty(findstr(' ',Session(j).con))
                Session(j).con(findstr(' ',Session(j).con)) = '';
            end
            
            cd(fullfile(opt.derivativesDir,RFX_FolderName))
            mkdir(Session(j).con)
            matlabbatch{j}.spm.stats.factorial_design.dir = {...
                fullfile(opt.derivativesDir,...
                RFX_FolderName,...
                Session(j).con)};
        end
        
        % Go to Jobs directory and save the matlabbatch
        cd(JOBS_dir)
        eval (['save jobs_RFX_',ExperimentName])
        fprintf(1,'Factorial Design Specification...')
        spm_jobman('run',matlabbatch)
        matlabbatch = {};
        
        %% Factorial design estimation
        fprintf(1,'BUILDING JOB: Factorial Design Estimation')
        
        for j = 1:size(Session,2)
            matlabbatch{j}.spm.stats.fmri_est.spmmat = {...
                fullfile(opt.derivativesDir,...
                RFX_FolderName,...
                Session(j).con,...
                'SPM.mat')};
            matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
        end
        
        % Go to Jobs directory and save the matlabbatch
        cd(JOBS_dir)
        eval (['save jobs_RFX_',ExperimentName,'_modelEstimation'])
        fprintf(1,'Factorial Design Estimation...')
        spm_jobman('run',matlabbatch)
        matlabbatch = {};
        
        %Contrast estimation
        fprintf(1,'BUILDING JOB: Contrast estimation')
        
        % ADD/REMOVE CONTRASTS DEPENDING ON YOUR EXPERIMENT AND YOUR GROUPS
        for j = 1:size(Session,2)
            matlabbatch{j}.spm.stats.con.spmmat = {...
                fullfile(opt.derivativesDir,...
                RFX_FolderName,...
                Session(j).con,...
                'SPM.mat')};
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'GROUP';
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = [1];
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            
            %             matlabbatch{j}.spm.stats.con.consess{2}.tcon.name = 'CATARACT';
            %             matlabbatch{j}.spm.stats.con.consess{2}.tcon.convec = [0 1];
            %             matlabbatch{j}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
            %
            %             matlabbatch{j}.spm.stats.con.consess{3}.tcon.name = 'CATARACT + CONTROL';
            %             matlabbatch{j}.spm.stats.con.consess{3}.tcon.convec = [1 1];
            %             matlabbatch{j}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
            %
            %             matlabbatch{j}.spm.stats.con.consess{4}.tcon.name = 'CONTROL > CATARACT';
            %             matlabbatch{j}.spm.stats.con.consess{4}.tcon.convec = [1 -1];
            %             matlabbatch{j}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
            %
            %             matlabbatch{j}.spm.stats.con.consess{5}.tcon.name = 'CATARACT > CONTROL';
            %             matlabbatch{j}.spm.stats.con.consess{5}.tcon.convec = [-1 1];
            %             matlabbatch{j}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
            
            matlabbatch{j}.spm.stats.con.delete = 0;
        end
        
        % Go to Jobs directory and save the matlabbatch
        cd(JOBS_dir)
        eval (['save jobs_RFX_',ExperimentName,'_contrasts'])
        fprintf(1,'Contrast Estimation...')
        spm_jobman('run',matlabbatch)
        matlabbatch = {};
        
end

cd(WD);

end

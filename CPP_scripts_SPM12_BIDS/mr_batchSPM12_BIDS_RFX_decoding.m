function mr_batchSPM12_BIDS_RFX_decoding(action,mm_Functional_Smoothing,mm_Con_Smoothing)
% This script smooth all con images created at the fisrt level in each
% subject, create a mean structural image and mean mask over the
% population, process the factorial design specification  and estimation and estimate Contrats.

% case 1 : smooth con images
% case 2 : Mean Struct, MeanMask, Factorial design specification and
% estimation, Contrst estimation

%mm_Functional_Smoothing = How much smoothing was applied to the functional data in the preprocessing
%mm_Con_Smoothing = How much smoothing is required for the CON images for the second level analysis

% You input is twofold :
% 1. Specify your data at the beginning of the script
% 2. In the origdir, create a structure containing all possible contrasts,
% example: ConOfInterest.mat containing the structure Session.con (contrasts of interest by group)
% IMPORTANT: To create the structure, use the script "List_of_Contrast.m"
% The Contrast names should match those in the single level FFX and in THE
% SAME ORDER.


% Get the current working directory
WD = pwd;

% load the subjects/Groups information and the task name
[derivativesDir,taskName,group] = getData();

% JOBS Directory
JOBS_dir = fullfile(derivativesDir,'JOBS',taskName);


matlabbatch = [];

% Check which level of CON smoothing is desired
if mm_Con_Smoothing==0
    smoothOrNonSmooth = '';
elseif mm_Con_Smoothing > 0
    smoothOrNonSmooth = ['s',num2str(mm_Con_Smoothing)];
else
    error ('Check you Con files')
end

% TASK NAME
ExperimentName = taskName;

origdir = pwd;
cont = 0;

switch action
    case 1 % Smooth all con images
        
        matlabbatch = {};
        
        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)
            groupName = group(iGroup).name ;    % Get the Group Name
            
            for iSub = 1:group(iGroup).numSub   % For each subject
                SubNumber = group(iGroup).SubNumber(iSub) ;   % Get the Subject ID
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                
                % FFX Directory
                ffx_dir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',1)],...
                    ['ffx_',taskName],['ffx_',num2str(mm_Functional_Smoothing),'/']);%% change according to files
                cd(ffx_dir)
                
                % Get the CON files
                ConFile = dir(['con_*.nii']) ;
                for j = 1:size(ConFile,1)
                    cont = cont +1;
                    matlabbatch{1}.spm.spatial.smooth.data{cont,:} = [pwd '/' ConFile(j).name];
                end
                
                
            end
        end
        
        % Define how much smoothing is required
        matlabbatch{1}.spm.spatial.smooth.fwhm = [mm_Con_Smoothing mm_Con_Smoothing mm_Con_Smoothing];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = ['s',num2str(mm_Con_Smoothing)];
        
        % Got to JOBS directory and save the matlabbatch
        cd(JOBS_dir)
        eval (['save jobs_SmoothCon_SPM8_',ExperimentName])
        fprintf(1,'SMOOTHING CON IMAGES...')
        spm_jobman('run',matlabbatch)
        
    case 2
        
        matlabbatch = {};
        
        % Define the RFX folder name and create it in the derivatives
        % directory
        RFX_FolderName = fullfile(['RFX_',taskName],['RFX_FunctSmooth',num2str(mm_Functional_Smoothing),'_ConSmooth_',num2str(mm_Con_Smoothing)]) ;
        cd(derivativesDir)
        mkdir(RFX_FolderName)
        
        % Create Mean Structural Image
        fprintf(1,'BUILDING JOB: Create Mean Structural Image...')
        
        subCounter=0;
        for iGroup= 1:length(group)                    % For each group
            groupName = group(iGroup).name ;           % Get the group name
            
            for iSub = 1:group(iGroup).numSub          % For each subject
                ises = 1;
                SubNumber = group(iGroup).SubNumber(iSub) ;
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                SubStrucDataDir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',ises)],'anat');
                cd(SubStrucDataDir)
                StructFileName = dir('wm*.nii');
                StructFileName = StructFileName.name;
                StructFile{1} =  StructFileName;
                subCounter = subCounter+1;
                matlabbatch{1}.spm.util.imcalc.input{subCounter,:} = [pwd '/' StructFile{1}];
            end
        end
        
        
        %% Generate the equation to get the mean of the mask and strucutral image
        % example : if we have 5 subjects, Average equation = '(i1+i2+i3+i4+i5)/5'
        tmp_images = [] ;
        num_images = subCounter ;
        image_num  = 1:subCounter ;
        
        tmp_images=sprintf('+i%i',image_num) ;
        tmp_images=tmp_images(2:end) ;
        
        Sum_equation = ['(',tmp_images,')'] ;
        meanStruct_equation = ['(',tmp_images,')/',num2str(length(image_num))] ;     % meanStruct_equation = '(i1+i2+i3+i4+i5)/5'
        meanMask_equation = strcat(Sum_equation,'>0.75*',num2str(num_images))  ;     % meanMask_equation = '(i1+i2+i3+i4+i5)>0.75*5'
        
        %%
        matlabbatch{1}.spm.util.imcalc.output = 'MeanStruct.nii';
        matlabbatch{1}.spm.util.imcalc.outdir{:} = fullfile(derivativesDir,RFX_FolderName);
        matlabbatch{1}.spm.util.imcalc.expression = meanStruct_equation ;
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        
        % Create Mask Image
        fprintf(1,'BUILDING JOB: Create Mask Image...')
        subCounter=0;
        for iGroup= 1:length(group)             % For each group
            groupName = group(iGroup).name ;    % Get the group name
            
            for iSub = 1:group(iGroup).numSub   % For each subject
                SubNumber = group(iGroup).SubNumber(iSub) ; % Get the subject ID
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                
                % FFX DIRECTORY
                ffx_dir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',1)],...
                    ['ffx_',taskName],['ffx_',num2str(mm_Functional_Smoothing),'/']);%% change according to files
                cd(ffx_dir)
                MaskFileName = dir('mask*.nii');
                MaskFileName = MaskFileName.name;
                MaskFile{1} =  MaskFileName;
                subCounter = subCounter+1;
                matlabbatch{2}.spm.util.imcalc.input{subCounter,:} = [pwd '/' MaskFile{1}];
                
            end
        end
        
        %% The mean mask will be saved in the RFX folder
        matlabbatch{2}.spm.util.imcalc.output = 'Meanmask.nii';
        matlabbatch{2}.spm.util.imcalc.outdir{:} = fullfile(derivativesDir,RFX_FolderName);
        matlabbatch{2}.spm.util.imcalc.expression = meanMask_equation ;
        matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{2}.spm.util.imcalc.options.mask = 0;
        matlabbatch{2}.spm.util.imcalc.options.interp = 1;
        matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
        
        cd(JOBS_dir)
        eval (['save jobs_SPM8_',ExperimentName,'_MeanStructural_MeanMask' ])
        fprintf(1,'Create Mean Struct and Mask IMAGES...')
        spm_jobman('run',matlabbatch)
        matlabbatch = {};
        
        % Factorial design specification
        fprintf(1,'BUILDING JOB: Factorial Design Specification')
        cd(origdir)
        %% Load the list of contrasts on interest for the RFX
        eval (['load ConOfInterest']) % In this mat file, there should be the contrasts of interests to analyze. They should match the name and order of those in the FFX folder.
        con = 0;
        
        % For each contrast
        for j = 1:size(Session,2)
            
            range = {};
            con = con+1;
            
            %subCounter=0;
            % For each group
            for iGroup= 1:length(group)
                groupName = group(iGroup).name ;
                
                for iSub = 1:group(iGroup).numSub       % For each subject
                    SubNumber = group(iGroup).SubNumber(iSub) ;  % Get the subject ID
                    fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n',groupName,iSub,SubNumber)
                    
                    % FFX DIRECTORY
                    ffx_dir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',SubNumber)],['ses-',sprintf('%02d',1)],...
                        ['ffx_',taskName],['ffx_',num2str(mm_Functional_Smoothing),'/']);%% change according to files
                    cd(ffx_dir)
                    
                    a = Session(j).con;
                    ConList = dir(sprintf([smoothOrNonSmooth,'con_%0.4d.nii'],con));
                    range{iGroup}.donnees{iSub,:} = [pwd '/' ConList.name];
                    
                    
                end
                
                a = [];
                for i = 1:size(range{iGroup}.donnees,1)
                    a = [a;isempty(range{iGroup}.donnees{i})];
                end
                c = find(a==0);
                for pp = 1:size(c,1)
                    matlabbatch{j}.spm.stats.factorial_design.des.fd.icell(iGroup).levels = iGroup;
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
            matlabbatch{j}.spm.stats.factorial_design.masking.em = { fullfile(derivativesDir,RFX_FolderName,'Meanmask.nii')};
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
            
            cd(fullfile(derivativesDir,RFX_FolderName))
            mkdir(Session(j).con)
            matlabbatch{j}.spm.stats.factorial_design.dir = {fullfile(derivativesDir,RFX_FolderName,Session(j).con)};
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
            matlabbatch{j}.spm.stats.fmri_est.spmmat = {fullfile(derivativesDir,RFX_FolderName,Session(j).con,'SPM.mat')};
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
            matlabbatch{j}.spm.stats.con.spmmat = {fullfile(derivativesDir,RFX_FolderName,Session(j).con,'SPM.mat')};
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


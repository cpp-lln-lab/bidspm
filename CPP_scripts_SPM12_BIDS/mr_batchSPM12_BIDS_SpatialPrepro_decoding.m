function mr_batchSPM12_BIDS_SpatialPrepro_decoding(opt)
%% The scripts performs spatial preprocessing of the functional and structural data.
% The structural data are segmented and normalized to MNI space.
% The functional data are re-aligned, coregistered with the structural and
% normalized to MNI space.


spmLocation = spm('dir');

% Get the working directory
WD = pwd;

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% Indicate which session the structural data was collected
StructSession = 1;

matlabbatch = [];

% creates prefix to look for
if isfield(opt, 'numDummies') && opt.numDummies>0
    prefix = opt.dummy_prefix;
else
    prefix = '';
end
if isfield(opt.metadata, 'SliceTiming') && ~isempty(opt.metadata.SliceTiming)
    prefix = [prefix opt.STC_prefix];
end

fprintf(1,'DOING PREPROCESSING\n')



%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)                 % For each group
    groupName = group(iGroup).name ;        % Get the group name
    
    for iSub = 1:group(iGroup).numSub       % For each Subject in the group
        
        % Get the ID of the subject
        %(i.e SubNumber doesnt have to match the iSub if one subject is exluded for any reason)
        subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID
        fprintf(1,' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',groupName,iSub,subNumber)
        
        sessions = spm_BIDS(BIDS, 'sessions', ...
            'sub', subNumber, ...
            'task', opt.taskName);
        numSessions = size(sessions,2);
        if numSessions==0
            numSessions = 1;
            sessions = {''};
        end
        
        % get all runs for that subject across all sessions
        runs = spm_BIDS(BIDS, 'data', ...
            'sub', subNumber, ...
            'ses', sessions{1}, ...
            'type', 'T1w');
        
        %% Structural file directory
        subStrucDataDir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',subNumber)],['ses-',sprintf('%02d',StructSession)],'anat');
        
        %unzip nii.gz structural file to be read by SPM
        struct = fullfile(subStrucDataDir,['sub-',groupName,sprintf('%02d',subNumber),'_ses-',sprintf('%02d',StructSession),'_T1w.nii.gz']) ;
        struct = load_untouch_nii(struct) ;
        save_untouch_nii(struct,fullfile(subStrucDataDir,['sub-',groupName,sprintf('%02d',subNumber),'_ses-',sprintf('%02d',StructSession),'_T1w.nii'])) ;
        
        % NAMED FILE SELECTOR
        matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Structural';
        [structImage] = fullfile(subStrucDataDir,['sub-',groupName,sprintf('%02d',subNumber),'_ses-',sprintf('%02d',StructSession),'_T1w.nii']) ;
        matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {structImage} };
        
        %% REALIGN
        
        fprintf(1,'BUILDING SPATIAL JOB : REALIGN\n')
        ses_counter = 1;
        numSessions = group(iGroup).numSess(iSub);   % Number of sessions for this subject in this group
        for ises = 1:numSessions                     % For each session
            
            % Define the functional data directory
            subFuncDataDir = fullfile(derivativesDir,['sub-',groupName,sprintf('%02d',subNumber)],['ses-',sprintf('%02d',ises)],'func');
            
            % Get the number of runs of this session in this subject in this Group
            numRuns = group(iGroup).numRuns(iSub);
            for iRun = 1:numRuns                     % For each run
                
                % If there is 1 run, get the functional files (note that the name does not contain -run-01)
                % If more than 1 run, get the functional files that contain the run number in the name
                if numRuns==1
                    files{1,1} = fullfile(subFuncDataDir,...
                        ['adr_sub-',groupName,sprintf('%02d',subNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_bold.nii']);
                elseif numRuns >1
                    files{1,1} = fullfile(subFuncDataDir,...
                        ['adr_sub-',groupName,sprintf('%02d',subNumber),'_ses-',sprintf('%02d',ises),'_task-',taskName,'_run-',sprintf('%02d',iRun),'_bold.nii']);
                end
                
                matlabbatch{2}.spm.spatial.realign.estwrite.data{ses_counter} =  cellstr(files);
                ses_counter = ses_counter + 1;
                
            end
        end
        
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = {''};
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 3;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
        
        
        % COREGISTER
        % REFERENCE IMAGE : DEPENDENCY FROM NAMED FILE SELECTOR ('Structural')
        fprintf(1,' BUILDING SPATIAL JOB : COREGISTER\n')
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep;
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tname = 'Reference Image';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).name = 'class';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).value = 'cfg_files';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).sname = 'Named File Selector: Structural(1) - Files';
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).src_exbranch = ...
            substruct('.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).src_output = substruct('.','files', '{}',{1});
        
        
        % SOURCE IMAGE : DEPENDENCY FROM REALIGNEMENT ('Realign: Estimate & Reslice: Mean Image')
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1) = cfg_dep;
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).tname = 'Source Image';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).value = 'image';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).sname = 'Realign: Estimate & Reslice: Mean Image';
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).src_exbranch = ...
            substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{3}.spm.spatial.coreg.estimate.source(1).src_output = substruct('.','rmean');
        
        
        % OTHER IMAGES : DEPENDENCY FROM REALIGNEMENT ('Realign: Estimate & Reslice: Realigned Images (Sess 1 to N)')
        % files %%
        for ises = 1:ses_counter-1 % '-1' because I added 1 extra session to ses_counter
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises) = cfg_dep;
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).tname = 'Other Images';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).tgt_spec{1}(1).name = 'filter';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).tgt_spec{1}(1).value = 'image';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).tgt_spec{1}(2).name = 'strtype';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).tgt_spec{1}(2).value = 'e';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).sname = ...
                ['Realign: Estimate & Reslice: Realigned Images (Sess ' (ises) ')'];
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).src_exbranch = ...
                substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
            matlabbatch{3}.spm.spatial.coreg.estimate.other(ises).src_output = ...
                substruct('.','sess', '()',{ises}, '.','cfiles');
        end
        % estimation options
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = ...
            [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SEGMENT STRUCTURALS (WITH NEW SEGMENT -DEFAULT SEGMENT IN
        % SPM12)
        % DATA : DEPENDENCY FROM NAMED FILE SELECTOR ('Structural')
        fprintf(1,' BUILDING SPATIAL JOB : SEGMENT STRUCTURAL\n');
        
        % SAVE BIAS CORRECTED IMAGE
        matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = ...
            cfg_dep('Named File Selector: Structural(1) - Files', ...
            substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','files', '{}',{1}));
        matlabbatch{4}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{4}.spm.spatial.preproc.channel.write = [0 1];
        
        % CREATE SEGMENTS IN NATIVE SPACE OF GM,WM AND CSF (CSF - in case I want to compute TIV later - stefbenet)
        
        matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {[spmLocation,'tpm/TPM.nii,1']};
        matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {[spmLocation,'tpm/TPM.nii,2']};
        matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {[spmLocation,'tpm/TPM.nii,3']};
        matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {[spmLocation,'tpm/TPM.nii,4']};
        matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {[spmLocation,'tpm/TPM.nii,5']};
        matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {[spmLocation,'tpm/TPM.nii,6']};
        matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
        
        % SAVE FORWARD DEFORMATION FIELD FOR NORMALISATION
        matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{4}.spm.spatial.preproc.warp.write = [1 1];
        
        % NORMALIZE FUNCTIONALS
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE FUNCTIONALS\n');
        matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = ...
            cfg_dep('Segment: Forward Deformations', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','fordef', '()',{':'}));
        matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Coregister: Estimate: Coregistered Images', ...
            substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','cfiles'));
        matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70 ; 78 76 85];
        matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [2 2 2];%original voxel size at acquisition
        matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        % NORMALIZE STRUCTURAL
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE STRUCTURAL\n');
        matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = ...
            cfg_dep('Segment: Forward Deformations', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','fordef', '()',{':'}));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: Bias Corrected (1)', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
        matlabbatch{6}.spm.spatial.normalise.write.woptions.bb  = [-78 -112 -70 ; 78 76 85];
        matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [1 1 1];% size 3 allow to run RunQA / original voxel size at acquisition
        matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        
        % NORMALIZE GREY MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE GREY MATTER\n');
        matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = ...
            cfg_dep('Segment: Forward Deformations', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','fordef', '()',{':'}));
        matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c1 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
        matlabbatch{7}.spm.spatial.normalise.write.woptions.bb  = [-78 -112 -70 ; 78 76 85];
        matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = [2 2 2];% size 3 allow to run RunQA / original voxel size at acquisition
        matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{7}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        % NORMALIZE WHITE MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE WHITE MATTER\n');
        matlabbatch{8}.spm.spatial.normalise.write.subj.def(1) = ...
            cfg_dep('Segment: Forward Deformations', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','fordef', '()',{':'}));
        matlabbatch{8}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c2 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
        matlabbatch{8}.spm.spatial.normalise.write.woptions.bb  = [-78 -112 -70 ; 78 76 85];
        matlabbatch{8}.spm.spatial.normalise.write.woptions.vox = [2 2 2];% size 3 allow to run RunQA / original voxel size at acquisition
        matlabbatch{8}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{8}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        % NORMALIZE CSF MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE CSF\n');
        matlabbatch{9}.spm.spatial.normalise.write.subj.def(1) = ...
            cfg_dep('Segment: Forward Deformations', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','fordef', '()',{':'}));
        matlabbatch{9}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c3 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
        matlabbatch{9}.spm.spatial.normalise.write.woptions.bb  = [-78 -112 -70 ; 78 76 85];
        matlabbatch{9}.spm.spatial.normalise.write.woptions.vox = [2 2 2];% size 3 allow to run RunQA / original voxel size at acquisition
        matlabbatch{9}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{9}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        % SAVING JOBS
        %Create the JOBS directory if it doesnt exist
        JOBS_dir = fullfile(subFuncDataDir, opt.JOBS_dir);
        [~, ~, ~] = mkdir(JOBS_dir);
        
        save(fullfile(JOBS_dir, 'jobs_SpatialPrepocess_matlabbatch_SPM12.mat'), 'matlabbatch') % save the matlabbatch
        spm_jobman('run',matlabbatch)
        
        
    end
end

cd(WD)

end


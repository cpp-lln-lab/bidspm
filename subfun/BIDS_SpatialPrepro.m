function BIDS_SpatialPrepro(opt)
%% The scripts performs spatial preprocessing of the functional and structural data.
% The structural data are segmented and normalized to MNI space.
% The functional data are re-aligned, coregistered with the structural and
% normalized to MNI space.

%% TO DO
% find a way to paralelize this over subjects


% if input has no opt, load the opt.mat file
if nargin<1
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% define SPM folder
spmLocation = spm('dir');

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% Indicate which session the structural data was collected
structSession = 1;

% creates prefix to look for
prefix = getPrefix('preprocess',opt);

fprintf(1,'DOING PREPROCESSING\n')

%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)                 % For each group
    groupName = group(iGroup).name ;        % Get the group name

    for iSub = 1:group(iGroup).numSub       % For each Subject in the group

        matlabbatch = [];
        % Get the ID of the subject
        %(i.e SubNumber doesnt have to match the iSub if one subject is exluded for any reason)
        subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID
        fprintf(1,' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
            groupName, iSub, subNumber)

        % identify sessions for this subject
        [sessions, numSessions] = getSessions(BIDS, subNumber, opt);

        % get all runs for that subject across all sessions
        struct = spm_BIDS(BIDS, 'data', ...
            'sub', subNumber, ...
            'ses', sessions{structSession}, ...
            'type', 'T1w');
        % we assume that the first T1w is the correct one (could be an
        % issue for data set with more than one
        struct = struct{1};


        %% Structural file directory
        [subStrucDataDir, structFile, ext] = spm_fileparts(struct);

        if strcmp(ext, '.gz')
            %unzip nii.gz structural file to be read by SPM
            struct = load_untouch_nii(struct);
            save_untouch_nii(struct, fullfile(subStrucDataDir, structFile));
            [structImage] = fullfile(subStrucDataDir, structFile);
        else
            [structImage] = fullfile(subStrucDataDir, [structFile ext]);
        end

        % NAMED FILE SELECTOR
        matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Structural';
        matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {structImage} };


        %% REALIGN
        fprintf(1,' BUILDING SPATIAL JOB : REALIGN\n')
        sesCounter = 1;

        for iSes = 1:numSessions                     % For each session

            % get all runs for that subject across all sessions
            [runs, numRuns] = getRuns(BIDS, subNumber, sessions{iSes}, opt);

            for iRun = 1:numRuns                     % For each run

                % get the filename for this bold run for this task
                [fileName, subFuncDataDir]= getBoldFilename(...
                    BIDS, ...
                    subNumber, sessions{iSes}, runs{iRun}, opt);
                
                % check that the file with the right prefix exist
                files = inputFileValidation(subFuncDataDir, prefix, fileName);

                % get native resolution to reuse it at normalisation;
                if ~isempty(opt.funcVoxelDims)         % If voxel dimensions is defined in the opt
                    voxDim = opt.funcVoxelDims;        % Get the dimension values
                else
                    hdr = spm_vol(fullfile(subFuncDataDir,[prefix,fileName]));  % SPM Doesnt deal with nii.gz and all our nii will be unzipped at this stage
                    voxDim = diag(hdr(1).mat);
                    voxDim = abs(voxDim(1:3)');    % Voxel dimensions are not pure integers before reslicing, therefore
                    voxDim = round(voxDim*10)/10;  % Round the dimensions of the functional files to the 1st decimal point
                    opt.funcVoxelDims = voxDim ;   % Add it to opt.funcVoxelDims to have the same value for all subjects and sessions
                end

                fprintf(1,' %s\n', files{1});

                matlabbatch{2}.spm.spatial.realign.estwrite.data{sesCounter} =  cellstr(files);
                
                sesCounter = sesCounter + 1;

            end
        end

        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = {''};
        
        % The following lines are commented out because those parameters
        % can be set in the spm_my_defaults.m
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 1;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 2;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        %         matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
        %         matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 3;
        %         matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        %         matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;

        

        %% COREGISTER
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
        for iSes = 1:sesCounter-1 % '-1' because I added 1 extra session to ses_counter
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes) = cfg_dep;
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).tname = 'Other Images';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(1).name = 'filter';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(1).value = 'image';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(2).name = 'strtype';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).tgt_spec{1}(2).value = 'e';
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).sname = ...
                ['Realign: Estimate & Reslice: Realigned Images (Sess ' (iSes) ')'];
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).src_exbranch = ...
                substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
            matlabbatch{3}.spm.spatial.coreg.estimate.other(iSes).src_output = ...
                substruct('.','sess', '()',{iSes}, '.','cfiles');
        end

        % The following lines are commented out because those parameters
        % can be set in the spm_my_defaults.m
        %         matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        %         matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        %         matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = ...
        %             [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        %         matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];


        %% SEGMENT STRUCTURALS
        % (WITH NEW SEGMENT -DEFAULT SEGMENT IN SPM12)
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
        matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',1']};
        matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',2']};
        matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',3']};
        matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 1];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',4']};
        matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',5']};
        matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = ...
            {[fullfile(spmLocation,'tpm', 'TPM.nii') ',6']};
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



        %% NORMALIZE FUNCTIONALS
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE FUNCTIONALS\n');

        for iJob = 5:9
            matlabbatch{iJob}.spm.spatial.normalise.write.subj.def(1) = ...
                cfg_dep('Segment: Forward Deformations', ...
                substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
                substruct('.','fordef', '()',{':'}));

            % The following lines are commented out because those parameters
            % can be set in the spm_my_defaults.m
            %             matlabbatch{iJob}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70 ; 78 76 85];
            %             matlabbatch{iJob}.spm.spatial.normalise.write.woptions.interp = 4;
            %             matlabbatch{iJob}.spm.spatial.normalise.write.woptions.prefix = spm_get_defaults('normalise.write.prefix');
        
        end

        matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Coregister: Estimate: Coregistered Images', ...
            substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','cfiles'));
        matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = voxDim;%original voxel size at acquisition


        % NORMALIZE STRUCTURAL
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE STRUCTURAL\n');
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: Bias Corrected (1)', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
        matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [1 1 1];% size 3 allow to run RunQA / original voxel size at acquisition

        % NORMALIZE GREY MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE GREY MATTER\n');
        matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c1 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
        matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = voxDim;% size 3 allow to run RunQA / original voxel size at acquisition

        % NORMALIZE WHITE MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE WHITE MATTER\n');
        matlabbatch{8}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c2 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
        matlabbatch{8}.spm.spatial.normalise.write.woptions.vox = voxDim;% size 3 allow to run RunQA / original voxel size at acquisition

        % NORMALIZE CSF MATTER
        fprintf(1,' BUILDING SPATIAL JOB : NORMALIZE CSF\n');
        matlabbatch{9}.spm.spatial.normalise.write.subj.resample(1) = ...
            cfg_dep('Segment: c3 Images', ...
            substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
            substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
        matlabbatch{9}.spm.spatial.normalise.write.woptions.vox = voxDim;% size 3 allow to run RunQA / original voxel size at acquisition


        %% SAVING JOBS
        %Create the JOBS directory if it doesnt exist
        JOBS_dir = fullfile(opt.JOBS_dir, subNumber);
        [~, ~, ~] = mkdir(JOBS_dir);

        save(fullfile(JOBS_dir, 'jobs_matlabbatch_SPM12_SpatialPrepocess.mat'), 'matlabbatch') % save the matlabbatch
        spm_jobman('run',matlabbatch)


    end
end

end

% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsSpatialPrepro(opt)
    % bidsSpatialPrepro(opt)
    %
    % Performs spatial preprocessing of the functional and structural data.
    % The structural data are segmented and normalized to MNI space.
    % The functional data are re-aligned, coregistered with the structural and
    % normalized to MNI space.
    %
    % The
    %
    % Assumptions:
    % - will take the first T1w images as reference
    % - assume the anatomical T1w to use for normalization is in the
    % first session
    % - the batch is build using dependencies across the different batch modules

    % TO DO
    % - find a way to paralelize this over subjects
    % - average T1s across sessions if necessarry

    % Indicate which session the structural data was collected
    structSession = 1;

    % if input has no opt, load the opt.mat file
    if nargin < 1
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    fprintf(1, 'DOING PREPROCESSING\n');

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            matlabbatch = [];
            % Get the ID of the subject
            % (i.e SubNumber doesnt have to match the iSub if one subject
            % is exluded for any reason)
            subID = group(iGroup).subNumber{iSub}; % Get the subject ID

            printProcessingSubject(groupName, iSub, subID);

            % identify sessions for this subject
            [sessions] = getInfo(BIDS, subID, opt, 'Sessions');

            fprintf(1, ' BUILDING SPATIAL JOB : SELECTING ANATOMCAL\n');
            % get all T1w images for that subject and
            anat = spm_BIDS(BIDS, 'data', ...
                'sub', subID, ...
                'ses', sessions{structSession}, ...
                'type', 'T1w');

            % we assume that the first T1w is the correct one (could be an
            % issue for dataset with more than one
            anat = anat{1};
            anatImage = unzipImgAndReturnsFullpathName(anat);

            matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
            matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {anatImage} };

            fprintf(1, ' BUILDING SPATIAL JOB : REALIGN\n');
            [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, subID, opt);

            fprintf(1, ' BUILDING SPATIAL JOB : COREGISTER\n');
            % REFERENCE IMAGE : DEPENDENCY FROM NAMED FILE SELECTOR ('Anatomical')
            matlabbatch = setBatchCoregistration(matlabbatch);

            fprintf(1, ' BUILDING SPATIAL JOB : SEGMENT ANATOMICAL\n');
            % (WITH NEW SEGMENT -DEFAULT SEGMENT IN SPM12)
            % DATA : DEPENDENCY FROM NAMED FILE SELECTOR ('Anatomical')
            matlabbatch = setBatchSegmentation(matlabbatch);

            fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE FUNCTIONALS\n');

            for iJob = 5:9
                matlabbatch{iJob}.spm.spatial.normalise.write.subj.def(1) = ...
                    cfg_dep('Segment: Forward Deformations', ...
                    substruct( ...
                    '.', 'val', '{}', {4}, ...
                    '.', 'val', '{}', {1}, ...
                    '.', 'val', '{}', {1}), ...
                    substruct('.', 'fordef', '()', {':'}));

                % The following lines are commented out because those parameters
                % can be set in the spm_my_defaults.m
                % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.bb = ...
                %  [-78 -112 -70 ; 78 76 85];
                % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.interp = 4;
                % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.prefix = ...
                %  spm_get_defaults('normalise.write.prefix');

            end

            matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = ...
                cfg_dep('Coregister: Estimate: Coregistered Images', ...
                substruct( ...
                '.', 'val', '{}', {3}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}), ...
                substruct('.', 'cfiles'));

            % original voxel size at acquisition
            matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = voxDim;

            % NORMALIZE STRUCTURAL
            fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE STRUCTURAL\n');
            matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = ...
                cfg_dep('Segment: Bias Corrected (1)', ...
                substruct( ...
                '.', 'val', '{}', {4}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}), ...
                substruct( ...
                '.', 'channel', '()', {1}, ...
                '.', 'biascorr', '()', {':'}));
            % size 3 allow to run RunQA / original voxel size at acquisition
            matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [1 1 1];

            % NORMALIZE GREY MATTER
            fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE GREY MATTER\n');
            matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = ...
                cfg_dep('Segment: c1 Images', ...
                substruct( ...
                '.', 'val', '{}', {4}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}), ...
                substruct( ...
                '.', 'tiss', '()', {1}, ...
                '.', 'c', '()', {':'}));
            % size 3 allow to run RunQA / original voxel size at acquisition
            matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = voxDim;

            % NORMALIZE WHITE MATTER
            fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE WHITE MATTER\n');
            matlabbatch{8}.spm.spatial.normalise.write.subj.resample(1) = ...
                cfg_dep('Segment: c2 Images', ...
                substruct( ...
                '.', 'val', '{}', {4}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}), ...
                substruct( ...
                '.', 'tiss', '()', {2}, ...
                '.', 'c', '()', {':'}));
            % size 3 allow to run RunQA / original voxel size at acquisition
            matlabbatch{8}.spm.spatial.normalise.write.woptions.vox = voxDim;

            % NORMALIZE CSF MATTER
            fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE CSF\n');
            matlabbatch{9}.spm.spatial.normalise.write.subj.resample(1) = ...
                cfg_dep('Segment: c3 Images', ...
                substruct( ...
                '.', 'val', '{}', {4}, ...
                '.', 'val', '{}', {1}, ...
                '.', 'val', '{}', {1}), ...
                substruct( ...
                '.', 'tiss', '()', {3}, ...
                '.', 'c', '()', {':'}));
            % size 3 allow to run RunQA / original voxel size at acquisition
            matlabbatch{9}.spm.spatial.normalise.write.woptions.vox = voxDim;

            saveMatlabBatch(matlabbatch, 'spatialPreprocessing', opt, subID);

            spm_jobman('run', matlabbatch);

        end
    end

end

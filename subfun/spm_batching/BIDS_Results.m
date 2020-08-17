function BIDS_Results(FFXSmoothing, ConSmoothing, opt, isMVPA)
    % This scripts computes the results for a series of contrast that can be
    % specified at the run, subject or dataset step level (see contrast specification following the BIDS stats model
    % specification)
    %
    % FFXSmoothing is the number of the mm smoothing used on the normalized functional files.
    % for unsmoothied data  FFXSmoothing = 0

    % if input has no opt, load the opt.mat file
    if nargin < 1
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    % JOBS Directory
    JOBS_dir = fullfile(opt.JOBS_dir);

    % load the subjects/Groups information and the task name
    [group, opt] = getData(opt);

    matlabbatch = [];

    % loop trough the steps and more results to compute for each contrast
    % mentioned for each step
    for iStep = 1:length(opt.result.Steps)

        for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

            % Depending on the level step we migh have to define a matlabbatch
            % for each subject or just on for the whole group
            switch opt.result.Steps(iStep).Level

                case 'run'
                    error('run level not implemented yet');

                case 'subject'

                    for iGroup = 1:length(group)

                        groupName = group(iGroup).name ;

                        % For each subject
                        for iSub = 1:group(iGroup).numSub

                            % Get the Subject ID
                            subNumber = group(iGroup).subNumber{iSub} ;

                            % FFX Directory
                            ffxDir = getFFXdir(subNumber, FFXSmoothing, opt, isMVPA);

                            load(fullfile(ffxDir, 'SPM.mat'));

                            % identify which contrast number actually has the name the user asked for
                            conNb = find (strcmp({SPM.xCon.name}', opt.result.Steps(iStep).Contrasts(iCon).Name));

                            if isempty(conNb)
                                sprintf('List of contrast in this SPM file');
                                disp({SPM.xCon.name}');
                                error('This SPM file %s does not contain a contrast named %s', ...
                                    fullfile(Dir, 'SPM.mat'), ...
                                    opt.result.Steps(1).Contrasts(iCon).Name);
                            end

                            matlabbatch = result_matlabbatch(matlabbatch, opt, iStep, iCon, ffxDir, conNb, subNumber, 1);

                        end
                    end

                case 'dataset'

                    % Define the RFX folder name and create it in the derivatives
                    % directory
                    rfxDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', ...
                        ['RFX_', opt.taskName], ...
                        ['RFX_FunctSmooth', num2str(FFXSmoothing), ...
                        '_ConSmooth_', num2str(ConSmoothing)], ...
                        opt.result.Steps(iStep).Contrasts(iCon).Name) ;

                    load(fullfile(rfxDir, 'SPM.mat'));

                    matlabbatch = result_matlabbatch(matlabbatch, opt, iStep, iCon, rfxDir, 1, 'group level', SPM.nscan);

            end
        end

    end

    if ~isempty(matlabbatch)
        % save the matlabbatch
        save(fullfile(JOBS_dir, ...
            'jobs_matlabbatch_SPM12_Results.mat'), ...
            'matlabbatch');

        spm_jobman('run', matlabbatch);

        % move ps file
        % TODO

        % rename NIDM file
        % TODO
    end

end

function matlabbatch = result_matlabbatch(matlabbatch, opt, iStep, iCon, Dir, conNb, label, nsubj)
    % outputs the typical matlabbatch to compute the results for a given
    % contrast

    matlabbatch{end + 1}.spm.stats.results.spmmat = {fullfile(Dir, 'SPM.mat')};

    matlabbatch{end}.spm.stats.results.conspec.titlestr = opt.result.Steps(iStep).Contrasts(iCon).Name;

    matlabbatch{end}.spm.stats.results.conspec.contrasts = conNb;

    matlabbatch{end}.spm.stats.results.conspec.threshdesc = opt.result.Steps(iStep).Contrasts(iCon).MC;

    matlabbatch{end}.spm.stats.results.conspec.thresh = opt.result.Steps(iStep).Contrasts(iCon).p;

    matlabbatch{end}.spm.stats.results.conspec.extent = opt.result.Steps(iStep).Contrasts(iCon).k;

    matlabbatch{end}.spm.stats.results.conspec.conjunction = 1;

    matlabbatch{end}.spm.stats.results.conspec.mask.none = ~opt.result.Steps(iStep).Contrasts(iCon).Mask;

    matlabbatch{end}.spm.stats.results.units = 1;

    matlabbatch{end}.spm.stats.results.export{1}.ps = true;

    if opt.result.Steps(1).Contrasts(iCon).NIDM

        matlabbatch{end}.spm.stats.results.export{2}.nidm.modality = 'FMRI';

        matlabbatch{end}.spm.stats.results.export{2}.nidm.refspace = 'ixi';

        matlabbatch{end}.spm.stats.results.export{2}.nidm.group.nsubj = nsubj;

        matlabbatch{end}.spm.stats.results.export{2}.nidm.group.label = label;

    end

end

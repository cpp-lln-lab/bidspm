% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsResults(opt, funcFWHM, conFWHM)
    % This scripts computes the results for a series of contrast that can be
    % specified at the run, subject or dataset step level (see contrast specification
    % following the BIDS stats model specification)
    %
    % funcFWHM is the number of the mm smoothing used on the normalized functional files.
    % for unsmoothied data  FFXSmoothing = 0

    % if input has no opt, load the opt.mat file
    if nargin < 1
        opt = [];
    end
    opt = loadAndCheckOptions(opt);

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
                    warning('run level not implemented yet');

                    % saveMatlabBatch(matlabbatch, 'computeFfxResults', opt, subID);

                case 'subject'

                    matlabbatch = ...
                        setBatchSubjectLevelResults( ...
                                                    matlabbatch, ...
                                                    group, ...
                                                    funcFWHM, ...
                                                    opt, ...
                                                    iStep, ...
                                                    iCon);

                    % TODO
                    % Save this batch in for each subject and not once for all

                    saveMatlabBatch(matlabbatch, 'compute_ffx_results', opt);

                case 'dataset'

                    rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

                    load(fullfile(rfxDir, 'SPM.mat'));

                    results.dir = rfxDir;
                    results.contrastNb = 1;
                    results.label = 'group level';
                    results.nbSubj = SPM.nscan;

                    matlabbatch = resultsMatlabbatch( ...
                                                     matlabbatch, opt, iStep, iCon, results);

                    saveMatlabBatch(matlabbatch, 'compute_rfx_results', opt);

            end
        end

    end

    if ~isempty(matlabbatch)

        spm_jobman('run', matlabbatch);

        % move ps file
        % TODO

        % rename NIDM file
        % TODO
    end

end

function batch = resultsMatlabbatch(batch, opt, iStep, iCon, results)
    % outputs the typical matlabbatch to compute the results for a given
    % contrast

    batch{end + 1}.spm.stats.results.spmmat = {fullfile(results.dir, 'SPM.mat')};

    batch{end}.spm.stats.results.conspec.titlestr = ...
        opt.result.Steps(iStep).Contrasts(iCon).Name;

    batch{end}.spm.stats.results.conspec.contrasts = results.contrastNb;

    batch{end}.spm.stats.results.conspec.threshdesc = ...
        opt.result.Steps(iStep).Contrasts(iCon).MC;

    batch{end}.spm.stats.results.conspec.thresh = opt.result.Steps(iStep).Contrasts(iCon).p;

    batch{end}.spm.stats.results.conspec.extent = opt.result.Steps(iStep).Contrasts(iCon).k;

    batch{end}.spm.stats.results.conspec.conjunction = 1;

    batch{end}.spm.stats.results.conspec.mask.none = ...
        ~opt.result.Steps(iStep).Contrasts(iCon).Mask;

    batch{end}.spm.stats.results.units = 1;

    batch{end}.spm.stats.results.export{1}.ps = true;

    if opt.result.Steps(1).Contrasts(iCon).NIDM

        batch{end}.spm.stats.results.export{2}.nidm.modality = 'FMRI';

        batch{end}.spm.stats.results.export{2}.nidm.refspace = 'ixi';
        if strcmp(opt.space, 'T1w')
            batch{end}.spm.stats.results.export{2}.nidm.refspace = 'subject';
        end

        batch{end}.spm.stats.results.export{2}.nidm.group.nsubj = results.nbSubj;

        batch{end}.spm.stats.results.export{2}.nidm.group.label = results.label;

    end

end

function batch = setBatchSubjectLevelResults(varargin)

    [batch, grp, funcFWHM, opt, isMVPA, iStep, iCon] = deal(varargin{:});

    for iGroup = 1:length(grp)

        % For each subject
        for iSub = 1:grp(iGroup).numSub

            % Get the Subject ID
            subID = grp(iGroup).subNumber{iSub};

            % FFX Directory
            ffxDir = getFFXdir(subID, funcFWHM, opt, isMVPA);

            load(fullfile(ffxDir, 'SPM.mat'));

            % identify which contrast nb actually has the name the user asked
            conNb = find( ...
                         strcmp({SPM.xCon.name}', ...
                                opt.result.Steps(iStep).Contrasts(iCon).Name));

            if isempty(conNb)
                sprintf('List of contrast in this SPM file');
                disp({SPM.xCon.name}');
                error( ...
                      'This SPM file %s does not contain a contrast named %s', ...
                      fullfile(ffxDir, 'SPM.mat'), ...
                      opt.result.Steps(1).Contrasts(iCon).Name);
            end

            results.dir = ffxDir;
            results.contrastNb = conNb;
            results.label = subID;
            results.nbSubj = 1;

            batch = resultsMatlabbatch( ...
                                       batch, opt, iStep, iCon, results);

        end
    end

end

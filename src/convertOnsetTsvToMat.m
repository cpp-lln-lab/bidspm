function fullpathOnsetFileName = convertOnsetTsvToMat(tsvFile, opt, isMVPA)
    %% Converts a tsv file to an onset file suitable for SPM ffx analysis
    % The scripts extracts the conditions' names, onsets, and durations, and
    % converts them to TRs (time unit) and saves the onset file to be used for
    % SPM
    %%

    % Read the tsv file
    t = spm_load(tsvFile);
    fprintf('reading the tsv file : %s \n', tsvFile);

    if ~isfield(t, 'trial_type')

        error('There was no trial_type field in the following file \n %s', tsvFile);

    end

    conds = t.trial_type; % assign all the tsv information to a variable called conds.

    % identify where the conditions to include that are specificed in the 'un' step of the
    % model file
    if isMVPA
        model = spm_jsonread(opt.model.multivariate.file);
    else
        model = spm_jsonread(opt.model.univariate.file);
    end

    for runIdx = 1:numel(model.Steps)
        if strcmp(model.Steps{1}.Level, 'run')
            break
        end
    end

    isTrialType = strfind(model.Steps{runIdx}.Model.X, 'trial_type.');

    % for each condition
    for iCond = 1:numel(isTrialType)

        if isTrialType{iCond}

            conditionName = strrep(model.Steps{runIdx}.Model.X{iCond}, ...
                'trial_type.', ...
                '');

            % Get the index of each condition by comparing the unique names and
            % each line in the tsv files
            idx = find(strcmp(conditionName, conds));

            % Get the onset and duration of each condition
            names{1, iCond} = conditionName;
            onsets{1, iCond} = t.onset(idx)'; %#ok<*AGROW,*NASGU>
            durations{1, iCond} = t.duration(idx)';

        end
    end

    % save the onsets as a matfile
    [path, file] = spm_fileparts(tsvFile);

    fullpathOnsetFileName = fullfile(path, ['onsets_' file '.mat']);

    save(fullpathOnsetFileName, ...
        'names', 'onsets', 'durations');

end

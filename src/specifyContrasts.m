% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function contrasts = specifyContrasts(ffxDir, taskName, opt, isMVPA)
    % Specifies the first level contrasts
    %
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

    load(fullfile(ffxDir, 'SPM.mat'));

    if isMVPA
        model = spm_jsonread(opt.model.multivariate.file);
    else
        model = spm_jsonread(opt.model.univariate.file);
    end

    contrasts = struct('C', [], 'name', []);
    con_counter = 0;

    % for the task of interest
    if ~strcmp(model.Input.task, taskName)
        return
    end

    % check all the steps specified in the model
    for iStep = 1:length(model.Steps)

        step = model.Steps(iStep);
        
        if iscell(step)
            step = step{1};
        end

        switch step.Level

            case 'run'

                [contrasts,  con_counter] = ...
                    specifyRunLvlContrasts(contrasts, step, con_counter, SPM);

            case 'subject'

                [contrasts,  con_counter] = ...
                    specifySubLvlContrasts(contrasts, step, con_counter, SPM);

        end

    end

end

function  [cdt_name, regIdx] = getRegIdx(conList, iCon, SPM, iCdt)
    % get regressors index corresponding to the HRF of of a condition

    if iscell(conList)
        cdt_name = conList{iCon};
    elseif isstruct(conList)
        cdt_name = conList(iCon).ConditionList{iCdt};
    end

    % get condition name
    cdt_name = strrep(cdt_name, 'trial_type.', '');

    % get regressors index corresponding to the HRF of that condition
    regIdx = strfind(SPM.xX.name', [' ' cdt_name '*bf(1)']);
    regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>

end

function [contrasts,  con_counter] = specifySubLvlContrasts(contrasts, Step, con_counter, SPM)

    if isfield(Step, 'AutoContrasts')

        % first the contrasts to compute automatically against baseline
        for iCon = 1:length(Step.AutoContrasts)

            con_counter = con_counter + 1;

            C = zeros(1, size(SPM.xX.X, 2));

            % get regressors index corresponding to the HRF of that condition
            [cdt_name, regIdx] = getRegIdx(Step.AutoContrasts, iCon, SPM);

            % give them a value of 1
            C(end, regIdx) = 1;

            % stores the specification
            contrasts(con_counter).C = C; %#ok<*AGROW>
            contrasts(con_counter).name = cdt_name;

        end

    end

    if isfield(Step, 'Contrasts')

        % then the contrasts that involve contrasting conditions
        % amongst themselves or something inferior to baseline
        for iCon = 1:length(Step.Contrasts)

            con_counter = con_counter + 1;

            C = zeros(1, size(SPM.xX.X, 2));

            for iCdt = 1:length(Step.Contrasts(iCon).ConditionList)

                % get regressors index corresponding to the HRF of that condition
                [~, regIdx] = getRegIdx(Step.Contrasts, iCon, SPM, iCdt);

                % give them a value of 1
                C(end, regIdx) = Step.Contrasts(iCon).weights(iCdt);

            end

            % stores the specification
            contrasts(con_counter).C = C;
            contrasts(con_counter).name =  ...
                Step.Contrasts(iCon).Name;

        end

    end

end

function [contrasts,  con_counter] = specifyRunLvlContrasts(contrasts, Step, con_counter, SPM)

    if isfield(Step, 'AutoContrasts')

        % first the contrasts to compute automatically against baseline
        for iCon = 1:length(Step.AutoContrasts)

            % get regressors index corresponding to the HRF of that condition
            [cdt_name, regIdx] = getRegIdx(Step.AutoContrasts, iCon, SPM);

            regIdx = find(regIdx);

            % For each event of each condition, create a seperate
            % contrast
            for iReg = 1:length(regIdx)

                C = zeros(1, size(SPM.xX.X, 2));

                % add a new line for a new contrast
                con_counter = con_counter + 1;
                C(end, regIdx(iReg)) = 1;   % give each event a value of 1

                % stores the specification
                contrasts(con_counter).C = C;
                contrasts(con_counter).name =  [cdt_name, '_', num2str(iReg)];

            end
        end

    end

end

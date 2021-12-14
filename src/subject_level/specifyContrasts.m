function contrasts = specifyContrasts(SPM, model)
    %
    % Specifies the first level contrasts
    %
    % USAGE::
    %
    %   contrasts = specifyContrasts(SPM, taskName, model)
    %
    % :param SPM: content of SPM.mat
    % :type SPM: structure
    % :param opt:
    % :type opt: structure
    %
    % :returns: - :contrasts: (type) (dimension)
    %
    % To know the names of the columns of the design matrix, type :
    % ``strvcat(SPM.xX.name)``
    %
    %
    % (C) Copyright 2019 CPP_SPM developers
    
    % TODO refactor code duplication between run level and subject level
    
    % TODO refactor with some of the functions from the bids-model folder ?
    
    % TODO what is the expected behavior if a condition is not present ?
    % - create a contrast with the name dummy ?
    % - do not create the contrast ?
    
    contrasts = struct('C', [], 'name', []);
    counter = 0;
    
    
    if numel(model.Nodes) < 1
        error('No node in the model');
    end
    
    % check all the nodes specified in the model
    for iNode = 1:length(model.Nodes)
        
        node = model.Nodes(iNode);
        
        if iscell(node)
            node = node{1};
        end
        
        switch lower(node.Level)
            
            case 'run'
                
                [contrasts,  counter] = ...
                    specifyRunLvlContrasts(contrasts, node, counter, SPM);
                
            case 'subject'
                
                [contrasts,  counter] = ...
                    specifySubLvlContrasts(contrasts, node, counter, SPM);
                
        end
        
    end
    
end

function  [cdtName, regIdx] = getRegIdx(cdtName, SPM)
    % get regressors index corresponding to the HRF of of a condition
    
    % get condition name
    cdtName = strrep(cdtName, 'trial_type.', '');
    
    % get regressors index corresponding to the HRF of that condition
    regIdx = strfind(SPM.xX.name', [' ' cdtName '*bf(1)']);
    regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>
    
    checkRegressorFound(regIdx, cdtName);
    
end

function [contrasts,  counter] = specifySubLvlContrasts(contrasts, node, counter, SPM)
    
    if isfield(node, 'DummyContrasts') && isfield(node.DummyContrasts, 'Contrasts')
        
        if isfield(node.DummyContrasts, 'Test') && node.DummyContrasts.Test ~= 't'
            warning('Only t test supported for dummy contrasts');
            
        else
            
            % first the contrasts to compute automatically against baseline
            for iCon = 1:length(node.DummyContrasts.Contrasts)
                
                % get regressors index corresponding to the HRF of that condition
                cdtName = node.DummyContrasts.Contrasts{iCon};

                [cdtName, regIdx] = getRegIdx(cdtName, SPM);
                C = newContrast(SPM, cdtName);
                
                % give them a value of 1
                C.C(end, regIdx) = 1;
                
                [contrasts, counter] = appendContrast(contrasts, C, counter);
                
                clear regIdx;
                
            end
            
        end
        
    end
    
    if isfield(node, 'Contrasts')
        
        % then the contrasts that involve contrasting conditions
        % amongst themselves or something inferior to baseline
        for iCon = 1:length(node.Contrasts)
            
            C = newContrast(SPM, node.Contrasts(iCon).Name);
            
            for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
                
                % get regressors index corresponding to the HRF of that condition
                cdtName = node.Contrasts(iCon).ConditionList{iCdt};
                [~, regIdx] = getRegIdx(cdtName, SPM);                
                
                % give them the value specified in the model
                C.C(end, regIdx) = node.Contrasts(iCon).Weights(iCdt);
                
                clear regIdx;
                
            end
            
            % TODO if one of the condition is not found, this contrast should
            % probably not be created ?
            
            [contrasts, counter] = appendContrast(contrasts, C, counter);
            
        end
        
    end
    
end

function [contrasts,  counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM)
    
    if isfield(node, 'DummyContrasts') && isfield(node.DummyContrasts, 'Contrasts')
        
        if isfield(node.DummyContrasts, 'Test') && node.DummyContrasts.Test ~= 't'
            warning('Only t test supported for dummy contrasts');
            
        else
            
            % first the contrasts to compute automatically against baseline
            for iCon = 1:length(node.DummyContrasts.Contrasts)
                
                % get regressors index corresponding to the HRF of that condition
                cdtName = node.DummyContrasts.Contrasts{iCon};
                [cdtName, regIdx] = getRegIdx(cdtName, SPM);
                
                % For each run of each condition, create a seperate contrast
                regIdx = find(regIdx);
                for iReg = 1:length(regIdx)
                    
                    C = newContrast(SPM, [cdtName, '_', num2str(iReg)]);

                    % give each event a value of 1
                    C.C(end, regIdx(iReg)) = 1;
                    [contrasts, counter] = appendContrast(contrasts, C, counter);

                end
                
                clear regIdx;
                
            end
            
        end
        
    end
    
    
    
    if isfield(node, 'Contrasts')
        
        % then the contrasts that involve contrasting conditions
        % amongst themselves or something inferior to baseline
        for iCon = 1:length(node.Contrasts)
            
            if isfield(node.Contrasts(iCon), 'Test') && ~strcmp(node.Contrasts(iCon).Test, 't')
                warning('Only t test supported for contrasts');
            end
            
            % get regressors index corresponding to the HRF of that condition
            for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
                cdtName = node.Contrasts(iCon).ConditionList{iCdt};
                [~, regIdx{iCdt}] = getRegIdx(cdtName, SPM);
                regIdx{iCdt} = find(regIdx{iCdt});
            end
            
            nbRuns = unique(cellfun(@numel, regIdx));
            
            if length(nbRuns) > 1
                disp(node.Contrasts(iCon).ConditionList);
                warning('Skipping contrast: some runs are missing a condition for the contrast "%s"', ...
                    node.Contrasts(iCon).Name);
                continue
            end
            
            % give them the value specified in the model
            for iRun = 1:nbRuns
                
                C = newContrast(SPM, [node.Contrasts(iCon).Name, '_', num2str(iRun)]);
                
                for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
                    C.C(end, regIdx{iCdt}(iRun)) = node.Contrasts(iCon).Weights(iCdt);
                end
                
                [contrasts, counter] = appendContrast(contrasts, C, counter);
                
            end
            clear regIdx;
            
        end
        
    end
    
end

function [contrasts, counter] = appendContrast(contrasts, C, counter)
    counter = counter + 1;
    contrasts(counter).C = C.C;
    contrasts(counter).name = C.name;
end

function C = newContrast(SPM, conName)
    C.C = zeros(1, size(SPM.xX.X, 2));
    C.name = conName;
end

function checkRegressorFound(regIdx, cdtName)
    regIdx = find(regIdx);
    if all(~regIdx)
        warning('No regressor found for condition "%s"', cdtName);
    end
end

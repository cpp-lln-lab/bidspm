function contrasts = pmCon(ffxDir, taskName, opt, isMVPA)
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

load(fullfile(ffxDir, 'SPM.mat'))

if isMVPA
    model = spm_jsonread(opt.model.multivariate.file);
else
    model = spm_jsonread(opt.model.univariate.file);
end

contrasts = struct('C',[],'name',[]);
con_counter = 0;


% for the task of interest
if strcmp(model.Input.task, taskName)
    
    % check all the steps specified in the model
    for iStep = 1:length(model.Steps)
        
        Step = model.Steps{iStep};
        
        switch Step.Level
            
            %% compute contrasts at the subject level
            case 'subject'
                
                % specify all the contrasts
                
                if isfield(Step, 'AutoContrasts')
                    
                    % first the contrasts to compute automatically against baseline
                    for iCon = 1:length(Step.AutoContrasts)
                        
                        con_counter = con_counter + 1;
                        
                        C = zeros(1,size(SPM.xX.X,2));
                        
                        % get regressors index corresponding to the HRF of that condition
                        [cdt_name, regIdx] = getRegIdx(Step, iCon, SPM);
                        
                        % give them a value of 1
                        C(end,regIdx) = 1;
                        
                        % stores the specification
                        contrasts(con_counter).C = C;
                        contrasts(con_counter).name = cdt_name;
                        
                    end
                    
                end
                
                
                if isfield(Step, 'Contrasts')
                    
                    % then the contrasts that involve contrasting conditions
                    % amongst themselves or something inferior to baseline
                    for iCon = 1:length(Step.Contrasts)
                        
                        con_counter = con_counter + 1;
                        
                        C = zeros(1,size(SPM.xX.X,2));
                        
                        for iCdt = 1:length(Step.Contrasts(iCon).ConditionList)
                            
                            % get regressors index corresponding to the HRF of that condition
                            [~, regIdx] = getRegIdx(Step, iCon, SPM);
                            
                            % give them a value of 1
                            C(end,regIdx) = Step.Contrasts(iCon).weights(iCdt);
                            
                        end
                        
                        % stores the specification
                        contrasts(con_counter).C = C;
                        contrasts(con_counter).name =  ...
                            Step.Contrasts(iCon).Name;
                        
                    end
                    
                end
                
                %% compute contrasts at the run level
            case 'run'
                
                % specify all the contrasts
                
                if isfield(Step, 'AutoContrasts')
                    
                    % first the contrasts to compute automatically against baseline
                    for iCon = 1:length(Step.AutoContrasts)
                        
                        % get regressors index corresponding to the HRF of that condition
                        [cdt_name, regIdx] = getRegIdx(Step, iCon, SPM);
                        
                        regIdx = find(regIdx);
                        
                        % For each event of each condition, create a seperate
                        % contrast
                        for iReg=1:length(regIdx)
                            
                            C = zeros(1,size(SPM.xX.X,2));
                            
                            % add a new line for a new contrast
                            con_counter = con_counter + 1;
                            C(end,regIdx(iReg)) = 1 ;   % give each event a value of 1
                            
                            % stores the specification
                            contrasts(con_counter).C = C;
                            contrasts(con_counter).name =  [cdt_name, '_', num2str(iReg)];
                            
                        end
                    end
                    
                end
        end
        
        
    end
end


end



function  [cdt_name, regIdx] = getRegIdx(Step, iCon, SPM)
% get regressors index corresponding to the HRF of of a condition

% get condition name
cdt_name = Step.AutoContrasts{iCon};
cdt_name = strrep(cdt_name, 'trial_type.', '');

% get regressors index corresponding to the HRF of that condition
regIdx = strfind(SPM.xX.name', [' ' cdt_name '*bf(1)']);
regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>

end
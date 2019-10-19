function [C, contrasts] = pmConMVPA(ffxDir, taskName, opt)
% Sepcifies the first level contrasts
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

model = spm_jsonread(opt.model.file);

contrasts = struct('C',[],'name',[]);
con_counter = 0;


% for the task of interest
if strcmp(model.Input.task, taskName)
    
    % check all the steps specified in the model
    for iStep = 1:length(model.Steps)
        
        % only compute contrasts at the subject level
        if strcmp(model.Steps{iStep}.Level, 'run')
            
            % specify all the contrasts
            
            % first the contrasts to compute automatically against baseline
            for iCon = 1:length(model.Steps{iStep}.AutoContrasts)
                                
                C = [];
                
                % get condition name
                cdt_name = model.Steps{iStep}.AutoContrasts{iCon};
                cdt_name = strrep(cdt_name, 'trial_type.', '');
                
                % get regressors index corresponding to the HRF of that condition
                regIdx = strfind(SPM.xX.name', [' ' cdt_name '*bf(1)']);
                regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>
                regIdx = find(regIdx);
                
                % For each event of each condition, create a seperate
                % contrast
                for iReg=1:length(regIdx)
                    
                    % add a new line for a new contrast
                    con_counter = con_counter + 1;
                    C(con_counter,:) = zeros(1,size(SPM.xX.X,2));
                    C(con_counter,regIdx(iReg)) = 1 ;   % give each event a value of 1
                    
                    % stores the specification
                    contrasts(con_counter).C = C(con_counter,:);
                    contrasts(con_counter).name =  [cdt_name,'_',num2str(iReg)];
                    
                end 
            end 
        end
    end
end


end



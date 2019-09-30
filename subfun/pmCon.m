function [C, contrasts] = pmCon(ffxDir, taskName, JOBS_dir, opt)
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


contrasts = struct('C',[],'name',[]);
line_counter = 0;
C = [];


%%

for iCon = 1:size(opt.contrastList,1)

    C = [C ; zeros(1,size(SPM.xX.X,2))]; % add 1 lign to C (more flexible than adding a fixed whole bunch at once)

    regIdx = strfind(SPM.xX.name', [' ' opt.contrastList{iCon}{1} '*bf(1)']);
    regIdx = ~cellfun('isempty', regIdx);

    C(end,regIdx) = 1;

    line_counter = line_counter + 1;
    contrasts(line_counter).C = C(end,:);
    contrasts(line_counter).name =  opt.contrastList{iCon}{1};

end



end

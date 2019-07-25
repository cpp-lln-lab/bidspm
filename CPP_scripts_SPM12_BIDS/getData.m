function [derivativesDir,taskName,group] = getData()
% The following structure will be the base that the scripts will use to run
% the preprocessing pipeline according to the BIDS Structure

% The directory where the derivatives are located
derivativesDir = '/Data/CrossMot_BIDS/derivatives';
% Name of the task
taskName = 'decoding';      

% Number of Sessions for each subject
NumberSessions = 1;
% Number of Runs for each subject
NumberRuns = 12;

% ADD the different groups in your experiment
%% GROUP 1
group(1).name = 'con';                                         % NAME OF THE GROUP
group(1).SubNumber = 1:4 ;                                     % SUBJECT ID .. con01 , con02 , etc. 
group(1).numSub = length(group(1).SubNumber) ;                 % Number of subjects in the group
group(1).numSess = ones(1,group(1).numSub) * NumberSessions ;  % Number of sessions in each subject
group(1).numRuns = ones(1,group(1).numSub) * NumberRuns ;      % Number of runs in each subject



% %% GROUP2
% group(1).name = 'con';
% group(1).SubNumber = 1:2 ; %1:4 %[1:13];  % Total 13
% group(1).numSub = length(group(1).SubNumber) ;
% group(1).numSess = ones(1,group(1).numSub) * NumberSessions ;
% group(1).numRuns = ones(1,group(1).numSub) * NumberRuns ;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%   IF THE NUMBER OF RUNS IS NOT THE SAME ACROSS PARTICIPANTS, THE     %
%   "group(1).numRuns" should be edited and corrected accordingly.     %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
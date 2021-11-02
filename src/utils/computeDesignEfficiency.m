function computeDesignEfficiency(tsvFile, opt)
    
    % opt.Ns = Number of scans (REQUIRED)
    %    opt.CM = Cell array of T or F contrast matrices (NOTE THAT THE L1 NORM OF CONTRASTS SHOULD
    %           MATCH IN ORDER TO COMPARE THEIR EFFICIENCIES, EG CM{1}=[1 -1 1 -1]/2 CAN BE
    %           COMPARED WITH CM{2}=[1 -1 0 0] BECAUSE NORM(Cm{i},1)==2 IN BOTH CASES
    %    opt.sots    = cell array of onset times for each condition in units of scans (OPTIONAL; SEE ABOVE)
    %    opt.durs    = cell array of durations for each condition in units of scans (OPTIONAL; SEE ABOVE)
    %    opt.HC = highpass filter cut-off (s) (DEFAULTS TO 120)
    %    opt.TR = inter-scan interval (s) (DEFAULTS TO 2)
    %    opt.t0 = initial transient (s) to ignore (DEFAULTS TO 30)
    
    
end


% Examples:
%
%   0. Simple user-specified blocked design
%
% S=[];
% S.TR = 1; 
% S.Ns = 1000;
% S.sots{1} = [0:48:1000];   % Condition 1 onsets
% S.sots{2} = [16:48:1000];  % Condition 2 onsets
% S.durs{1} = 16; S.durs{2} = 16;  % Both 16s epochs
% S.CM{1} = [1 -1]; S.CM{2} = [1 -1]; % Contrast conditions, and conditions vs baseline
% 
% [e,sots,stim,X,df] = fMRI_GLM_efficiency(S);

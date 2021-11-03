function e = computeDesignEfficiency(tsvFile, opt)
  %
  %    opt.modem.file : bids stats model file
  %
  %    opt.Ns = Number of scans
  %    opt.TR = inter-scan interval (s) (DEFAULTS TO 2)
  %    opt.t0 = initial transient (s) to ignore (DEFAULTS TO 30)
  %
  %    opt.sots    = cell array of onset times for each condition in units of scans
  %    opt.durs    = cell array of durations for each condition in units of scans
  %    opt.CM = Cell array of T or F contrast matrices
  %
  %    NOTE THAT THE L1 NORM OF CONTRASTS SHOULD
  %    MATCH IN ORDER TO COMPARE THEIR EFFICIENCIES, e.g CM{1}=[1 -1 1 -1]/2 CAN BE
  %    COMPARED WITH CM{2}=[1 -1 0 0] BECAUSE NORM(Cm{i},1)==2 IN BOTH CASES
  %
  % (C) Copyright 2020 Remi Gau

  plotEvents(tsvFile);

  data = getEventsData(tsvFile, opt.model.file);

  opt.sots = data.onset;
  opt.durs = data.duration;

  opt.HC = getHighPassFilter(opt.model.file);

  opt.contrast_name = {};
  opt.CM = {};

  %%
  autoContrastsList = getAutoContrastsList(opt.model.file);
  for i = 1:numel(autoContrastsList)
      contrast = filterTrialtypes(data.conditions, autoContrastsList{i});
    opt.CM{i} = contrast';
    opt.contrast_name{i} = autoContrastsList{i};
  end

  %%
  % TODO deal with F contrasts
  contrastsList = getContrastsList(opt.model.file);
  for i = 1:numel(contrastsList)
    contrast = zeros(size(opt.CM{end}));
    for cdt = 1:numel(contrastsList(i).ConditionList)
      idx = filterTrialtypes(data.conditions, contrastsList(i).ConditionList{cdt});
      contrast(idx) = contrastsList(i).weights(cdt);
    end
    opt.CM{end + 1} = contrast;
    opt.contrast_name{end + 1} = contrastsList(i).Name;
  end

  %%
  [e, ~, ~, X] = fMRI_GLM_efficiency(opt);

  for i = 1:numel(opt.CM)
    fprintf('Contrast %s: Efficiency = %f\n', opt.contrast_name{i}, e(1, i));
  end

  figure('name', 'design matrix', 'position', [50 50 1000 1000]);

  subplot(2, 3, [1 4]);
  colormap('gray');
  imagesc(X);
  title('design matrix');
  ylabel('scans');
  set(gca, 'xtick', 1:numel(data.conditions), 'xticklabel', data.conditions);

  subplot(2, 3, [2 3]);
  plot(X);
  title('temporal profile');
  xlabel('scans');
  legend(data.conditions);

  subplot(2, 3, [5 6]);
  plotFft(X, opt.TR, opt.HC);

end

function logicalIdx = filterTrialtypes(trialTypesList, conditionList)
    
    logicalIdx = ismember(cellfun(@(x) ['trial_type.' x], ...
                                trialTypesList, ...
                                'UniformOutput', false), ...
                        conditionList);
    
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

function plotFft(signal, rt, HPF)
  % USAGE fft_gui(signal, rt, HPF)
  % signal
  % rt = repetition time in seconds
  % HPF = high pass filter in seconds
  %
  % TODO add credit because I don't remember where I got this from. Cyril's
  % tuto?

  gX = abs(fft(signal)).^2;

  gX = gX * diag(1 ./ sum(gX));

  q = size(gX, 1);

  Hz = [0:(q - 1)] / (q * rt);

  q = 2:fix(q / 2);

  plot(Hz(q), gX(q, :));

  patch([0 1 1 0] / HPF, [0 0 1 1] * max(max(gX)), [1 1 1] * .9);

  xlabel('Frequency (Hz)');
  ylabel('relative spectral density');
  title(['Frequency domain', newline, ...
         ' {\bf', num2str(HPF), '}', ' second High-pass filter'], 'Interpreter', 'Tex');
  grid on;
  axis tight;
end

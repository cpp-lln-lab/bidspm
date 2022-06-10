function e = computeDesignEfficiency(tsvFile, opt)
  %
  % Calculate efficiency for fMRI GLMs. Relies on Rik Henson's fMRI_GLM_efficiency function.
  %
  % For more information on design efficiency, see `Jeanette Mumford excellent
  % videos <https://www.youtube.com/watch?v=FD4ztsoYvSY&list=PLB2iAtgpI4YEnBdb_jDGmMcdGoIBwhCCY>`_
  % and the dedicated videos from the `Principles of fMRI Part 2, Module 7-9
  % <https://www.youtube.com/watch?v=A5KazMd_Bck&list=PLfXA4opIOVrEFBitfTGRPppQmgKp7OO-F&index=8>`_.
  %
  % .. warning::
  %
  %   This function should NOT be used for proper design efficiency optimization as there are
  %   better tools for this.
  %
  %   In general see the `BrainPower doc <https://brainpower.readthedocs.io/en/latest/index.html>`_
  %   but more specifically the tools below:
  %
  %     - `neuropower <http://neuropowertools.org/neuropower/neuropowerstart/>`_
  %     - `some of the Canlab tools <https://github.com/canlab/CanlabCore/tree/master/CanlabCore/OptimizeDesign11>`_
  %
  % USAGE::
  %
  %     e = computeDesignEfficiency(tsvFile, opt)
  %
  % :param tsvFile: Path to a bids _events.tsv file.
  % :type tsvFile: string
  % :param opt: Options chosen for the analysis with the content below.
  % :type opt: structure
  %
  %
  % Required:
  %
  % - ``opt.model.file``: path to bids stats model file
  % -  ``opt.TR``: inter-scan interval (s) - can be read from the ``_bold.json``
  %
  % Optional:
  %
  % - ``opt.t0``: initial transient (s) to ignore (default = 1)
  % - ``opt.Ns``: number of scans
  %
  % See also: fMRI_GLM_efficiency
  %
  % ---
  %
  % EXAMPLE:
  %
  % .. code-block:: guess
  %
  %       %% create stats model JSON
  %       json = createEmptyStatsModel();
  %       runStepIdx = 1;
  %       json.Steps{runStepIdx}.Model.X = {'trial_type.cdt_A', 'trial_type.cdt_B'};
  %       json.Steps{runStepIdx}.DummyContrasts = {'trial_type.cdt_A', 'trial_type.cdt_B'};
  %
  %       contrast = struct('type', 't', ...
  %                         'Name', 'A_gt_B', ...
  %                         'weights', [1, -1], ...
  %                         'ConditionList', {{'trial_type.cdt_A', 'trial_type.cdt_B'}});
  %
  %       json.Steps{runStepIdx}.Contrasts = contrast;
  %
  %       bids.util.jsonwrite('smdl.json', json);
  %
  %       %% create events TSV file
  %       conditions = {'cdt_A', 'cdt_B'};
  %       IBI = 5;
  %       ISI = 0.1;
  %       stimDuration = 1.5;
  %       stimPerBlock = 12;
  %       nbBlocks = 10;
  %
  %       trial_type = {};
  %       onset = [];
  %       duration = [];
  %
  %       time = 0;
  %
  %       for iBlock = 1:nbBlocks
  %         for cdt = 1:numel(conditions)
  %           for iTrial = 1:stimPerBlock
  %             trial_type{end + 1} = conditions{cdt};
  %             onset(end + 1) = time;
  %             duration(end + 1) = stimDuration;
  %             time = time + stimDuration + ISI;
  %           end
  %           time = time + IBI;
  %         end
  %       end
  %
  %       tsv = struct('trial_type',  {trial_type}, 'onset', onset, 'duration', duration');
  %
  %       bids.util.tsvwrite('events.tsv', tsv);
  %
  %       opt.TR = 2;
  %
  %       opt.model.file = fullfile(pwd, 'smdl.json');
  %
  %       e = computeDesignEfficiency(fullfile(pwd, 'events.tsv'), opt);
  %
  %
  % (C) Copyright 2021 Remi Gau

  opt = checkOptions(opt);

  if ~isfield(opt, 't0') || isempty(opt.t0)
    opt.t0 = 1;
  end

  data = getEventsData(tsvFile, opt.model.file);

  maxTime = getMaxTime(data);
  if ~isfield(opt, 'Ns') || isempty(opt.Ns)
    opt.Ns = ceil(maxTime / opt.TR);
    warning('Setting opt.Ns (number of scans) to: %i', opt.Ns);
  end

  opt.sots = convertSecondsToScans(data.onset, opt.TR);
  opt.durs = convertSecondsToScans(data.duration, opt.TR);

  opt.contrast_name = {};
  opt.CM = {};

  bm = BidsModel('file', opt.model.file);
  opt.HC = bm.getHighPassFilter();

  DummyContrastsList = bm.get_dummy_contrasts('Level', 'Run');
  for i = 1:numel(DummyContrastsList.Contrasts)
    contrast = filterTrialtypes(data.conditions, DummyContrastsList.Contrasts{i});
    opt.CM{i} = contrast';
    opt.contrast_name{i} = DummyContrastsList.Contrasts{i};
  end

  %%
  % TODO deal with F contrasts
  contrastsList = bm.get_contrasts('Level', 'Run');
  for i = 1:numel(contrastsList)
    contrast = zeros(size(opt.CM{end}));
    for cdt = 1:numel(contrastsList{i}.ConditionList)
      idx = filterTrialtypes(data.conditions, contrastsList{i}.ConditionList{cdt});
      contrast(idx) = contrastsList{i}.Weights(cdt);
    end
    opt.CM{end + 1} = contrast;
    opt.contrast_name{end + 1} = contrastsList{i}.Name;
  end

  %%
  [e, ~, ~, X] = fMRI_GLM_efficiency(opt);

  if opt.verbosity
    for i = 1:numel(opt.CM)
      fprintf('Contrast %s: Efficiency = %f\n', opt.contrast_name{i}, e(1, i));
    end
  end

  if opt.verbosity && ~isGithubCi()

    plotEvents(tsvFile);

    figure('name', 'design matrix', 'position', [50 50 1000 1000]);

    % TODO add a second axis with scale in seconds

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

end

function values = convertSecondsToScans(values, TR)
  for i = 1:numel(values)
    values{i} = values{i} / TR;
  end
end

function maxTime = getMaxTime(data)
  for i = 1:numel(data.onset)
    offset{i} = data.onset{i} + data.duration{i};
  end
  % add 16 seconds because HRF is sluggish AF
  maxTime =  max(cellfun(@max, offset)) + 32;
end

function logicalIdx = filterTrialtypes(trialTypesList, conditionList)

  logicalIdx = ismember(cellfun(@(x) ['trial_type.' x], ...
                                trialTypesList, ...
                                'UniformOutput', false), ...
                        conditionList);

end

function plotFft(signal, rt, HPF)
  % USAGE fft_gui(signal, rt, HPF)
  % signal
  % rt = repetition time in seconds
  % HPF = high pass filter in seconds
  %
  % TODO add credit because I don't remember where I got this from.
  % Cyril's tuto?

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

function bidsQApreproc(opt, varargin)
  %
  % Use confounds preprocessed datasets to estimate
  % the number of timepoints with values superior to threshold.
  %
  %
  % plots the proportion of timepoints per run
  % (to identify runs with that goes above a limit)

  % (C) Copyright 2024 bidspm developers

  % TODO
  % - handle opt.bidsFilterFile
  %
  % could also plots the sum of the proportion of timepoints over the 4 runs
  % to identify participants whoe move a lot
  % but for whom no run goes above the threshold

  args = inputParser;
  addParameter(args, 'metric', 'framewise_displacement');
  addParameter(args, 'threshold', 0.2);
  parse(args, varargin{:});
  metric = args.Results.metric;
  threshold = args.Results.threshold;

  layoutFilter = struct('modality', {{'func'}});

  [BIDS, opt] = setUpWorkflow(opt, 'QA', opt.dir.input, true, false, layoutFilter);

  if ~isfield(opt, 'taskName')
    opt.taskName = '.*';
  end

  %% Load confounds to collect the metric for each run / subject
  % stores only the metric of interest

  df = struct('sub', '', metric, []);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    filter = fileFilterForBold(opt, subLabel, 'confounds');

    files = bids.query(BIDS, 'data', filter);

    for iRun = 1:numel(files)

      try
        data = spm_load(files{iRun});
      catch
        continue
      end

      if ~ismember(metric, fieldnames(data))
        continue
      end

      df(iSub).sub = subLabel;
      df(iSub).(metric){iRun} = data.(metric);

    end

  end

  nbSubjects = numel(df);

  %%  plot proportion datapoint with > threshold
  for iSub = 1:nbSubjects
    if isempty(df(iSub).(metric))
      continue
    end
    values = df(iSub).(metric);
    df(iSub).proportion_censored = cellfun(@(x) sum(x > threshold) / sum(~isnan(x)), values);
  end

  close all;

  plotFigure(df, metric, threshold);

end

function plotFigure(df, metric, threshold)

  nbSubjects = numel(df);

  figure('name', metric);

  hold on;

  x_tick_label = {df.sub};
  xtick = linspace(1.5,  nbSubjects + 0.5, nbSubjects);

  % collect subjects average
  avg = [];
  for iSub = 1:nbSubjects
    y = df(iSub).proportion_censored;

    avg(iSub) = mean(y);
    if numel(y) == 1
      x = xtick(iSub);
    elseif numel(y) == 2
      x = linspace(xtick(iSub) - 0.2, xtick(iSub) + 0.2, numel(y));
    elseif numel(y) == 3
      x = linspace(xtick(iSub) - 0.3, xtick(iSub) + 0.3, numel(y));
    else
      x = linspace(xtick(iSub) - 0.35, xtick(iSub) + 0.35, numel(y));
    end
    bar(x, y, 0.9);
    plot(xtick(iSub), mean(y), 'k.', 'MarkerSize', 10);
  end

  % plot group median
  plot([1 nbSubjects + 1], [median(avg) median(avg)], '-r');

  ylabel(sprintf('proportion time points %s > %0.5f / run', ...
                 strrep(metric, '_', ' '), ...
                 threshold));
  xlabel('subject');

  set(gca, 'xtick', xtick, ...
      'xticklabel', x_tick_label, ...
      'ytick', 0:.05:1, ...
      'yticklabel', 0:.05:1, ...
      'fontsize', 8, 'tickdir', 'out');

end

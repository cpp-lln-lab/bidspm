function plotEvents(eventsFile, modelFile)
  %
  % USAGE::
  %
  %   plotEvents(eventsFile, modelFile)
  %
  % :param eventsFile: Path to a bids _events.tsv file.
  % :type eventsFile: string
  % :param modelFile: Optional. Path to a bids statistical model file to filter
  %                   what events to plot.
  % :type modelFile: structure
  %
  % EXAMPLE::
  %
  %     dataDir = fullpath('bids-examples', 'ds001');
  % 
  %     eventsFile = bids.query(dataDir, ...
  %                             'data', ...
  %                             'sub', '01', ...
  %                             'task', 'balloonanalogrisktask', ...
  %                             'suffix', 'events');
  % 
  %     plotEvents(eventsFile{1});
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 2
    modelFile = '';
  end

  bidsFile = bids.File(eventsFile);

  figName = strrep(bidsFile.filename, '_', ' ');
  figName = strrep(figName, 'events.tsv', ' ');

  data = getEventsData(eventsFile, modelFile);

  conditions = data.conditions;
  onsets = data.onset;
  duration = data.duration;

  xMin = floor(min(cellfun(@min, onsets))) - 1;
  xMax = 0;

  yMin = 0;
  yMax = 1;

  if isGithubCi()
    return
  end

  spm_figure('Create', 'Tag', figName, 'on');

  for iCdt = 1:numel(conditions)

    subplot(numel(conditions), 1, iCdt);

    if all(duration{iCdt} == 0)
      stem(onsets{iCdt}, ones(1, numel(onsets{iCdt})));

      xMax = max(onsets{iCdt});

    else

      for iStim = 1:numel(onsets{iCdt})

        offset = onsets{iCdt} + duration{iCdt}(iStim);
        xMax = max([xMax; offset]);

        rectangle( ...
                  'position', [onsets{iCdt}(iStim) 0 duration{iCdt}(iStim) 1], ...
                  'FaceColor', 'r');
      end

    end

    ylabel(sprintf(strrep(conditions{iCdt}, '_', '\n')));

  end

  xMax = xMax + 5;

  for iCdt = 1:numel(conditions)

    subplot(numel(conditions), 1, iCdt);

    axis([xMin  xMax yMin yMax]);

    xlabel('seconds');

    subplot(numel(conditions), 1, 1);

  end

  title(figName);

end

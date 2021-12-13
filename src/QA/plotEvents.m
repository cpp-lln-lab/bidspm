function plotEvents(eventsFile, modelFile)
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

  figure('name', figName, 'position', [50 50 1000 200 * numel(conditions)]);

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

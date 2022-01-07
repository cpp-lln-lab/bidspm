function plotRoiTimeCourse(varargin)
  %
  % Plots the peristimulus histogram from a ROI based GLM
  %
  % USAGE::
  %
  %   plotRoiTimeCourse(tsvFile)
  %
  % :param tsvFile: obligatory argument.
  % :type tsvFile: path
  %
  % See also: bidsRoiBasedGLM(varargin)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  isFile = @(x) exist(x, 'file') == 2;

  addRequired(p, 'tsvFile', isFile);

  parse(p, varargin{:});

  tsvFile = p.Results.tsvFile;
  timeCourse = bids.util.tsvread(tsvFile);
  conditionNames = fieldnames(timeCourse);

  for i = 1:numel(conditionNames)
    tmp(:, i) = timeCourse.(conditionNames{i});
  end
  timeCourse = tmp;

  jsonFile = bids.internal.file_utils(tsvFile, 'ext', '.json');
  content = bids.util.jsondecode(jsonFile);

  secs = [0:size(timeCourse, 1) - 1] * content.SamplingFrequency;

  bf = bids.File(tsvFile);
  
  if isGithubCi()
    return
  end

  fig = figure('name', ['ROI: ' bf.entities.label ' - ' bf.entities.hemi], ...
               'position', [50 50 750 750]);

  hold on;

  plot(secs, timeCourse, 'linewidth', 2);
  plot([0 secs(end)], [0 0], '--k');

  title(['Time courses for ' get(fig, 'name')], ...
        'Interpreter', 'none');

  xlabel('Seconds');
  ylabel('Percent signal change');
  
  legend(conditionNames);

  axis tight;

  position = [20 max(timeCourse(:))/2];
  text(position(1), position(2), 'Max percent signal change')
  for i = 1:numel(conditionNames)
    text(position(1), position(2) - i * 0.015,  ...
      sprintf('%s = %f', ...
      conditionNames{i}, ...
      content.(conditionNames{i}).percentSignalChange))
  end

end

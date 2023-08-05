function figureFile = plotRoiTimeCourse(varargin)
  %
  % Plots the peristimulus histogram from a ROI based GLM
  %
  % USAGE::
  %
  %   plotRoiTimeCourse(tsvFile, verbose, 'colors', colors, 'roiName', roiName)
  %
  % :param tsvFile: Content of TSV is organized in a "BIDS" way.
  %                 Must be ``(t + 1) X c`` with t = time points and c = conditions.
  %                 The + 1 for the row dimension is because of the headers
  %                 giving the name of the condition.
  %                 A side car JSON is expected to contain a ``SamplingFrequency`` field
  %                 for the temporal resolution.
  % :type tsvFile: path
  %
  % :param verbose: to show figure or not
  % :type verbose: boolean
  %
  % :param colors:
  % :type colors: ``n X 3`` array
  %
  % :param roiName:
  % :type roiName: char
  %
  %
  % See also: bidsRoiBasedGLM
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  isFile = @(x) exist(x, 'file') == 2;

  addRequired(args, 'tsvFile', isFile);
  addOptional(args, 'verbose', true, @islogical);
  addParameter(args, 'colors', twelveClassesColorMap(), @isnumeric);
  addParameter(args, 'roiName', '', @ischar);

  parse(args, varargin{:});

  tsvFile = args.Results.tsvFile;
  timeCourse = bids.util.tsvread(tsvFile);
  if ~isstruct(timeCourse)
    tmp = struct('this_condition', timeCourse);
    timeCourse = tmp;
    clear tmp;
  end
  conditionNames = fieldnames(timeCourse);

  visible = 'off';
  if args.Results.verbose
    visible = 'on';
  end

  if strcmp(args.Results.roiName, '')
    bf = bids.File(tsvFile);
    figName = ['ROI: ' bf.entities.label];
    if isfield(bf.entities, 'hemi')
      figName = [figName ' - ' bf.entities.hemi];
    end
  else
    figName = ['ROI: ' args.Results.roiName];
  end

  for i = 1:numel(conditionNames)
    tmp(:, i) = timeCourse.(conditionNames{i});
  end
  timeCourse = tmp;

  jsonFile = bids.internal.file_utils(tsvFile, 'ext', '.json');
  jsonContent = bids.util.jsondecode(jsonFile);

  secs = [0:size(timeCourse, 1) - 1] * jsonContent.SamplingFrequency;

  colors = args.Results.colors;
  if size(timeCourse, 2) > size(colors, 1)
    colors = repmat(colors, 2, 1);
  end

  if bids.internal.is_github_ci()
    return
  end

  spm_figure('Create', 'Tag', figName, visible);

  hold on;

  l = plot(secs, timeCourse, 'linewidth', 2);
  for i = 1:numel(l)
    set(l(i), 'color', colors(i, :));
  end

  plot([0 secs(end)], [0 0], '--k');

  title(['Time courses for ' figName], ...
        'Interpreter', 'none');

  xlabel('Seconds');
  ylabel('Percent signal change');

  legend_content = regexprep(conditionNames, '_', ' ');

  axis tight;

  for i = 1:numel(conditionNames)
    if isfield(jsonContent, conditionNames{i})
      legend_content{i} = sprintf('%s ; max(PSC)= %0.2f', ...
                                  legend_content{i}, ...
                                  jsonContent.(conditionNames{i}).percentSignalChange.max);
    end
  end

  legend(legend_content);

  figureFile = bids.internal.file_utils(tsvFile, 'ext', '.png');
  if exist(figureFile, 'file')
    delete(figureFile);
  end
  print(gcf, figureFile, '-dpng');

end

function colors = twelveClassesColorMap()

  % from color brewer
  % https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12

  colors = [166, 206, 227
            31, 120, 180
            178, 223, 138
            51, 160, 44
            251, 154, 153
            227, 26, 28
            253, 191, 111
            255, 127, 0
            202, 178, 214
            106, 61, 154
            255, 255, 153
            177, 89, 40] / 256;

end

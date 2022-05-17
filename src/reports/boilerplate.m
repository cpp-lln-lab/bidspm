function outputFile = boilerplate(varargin)
  %
  % USAGE::
  %
  %     outputFile = boilerplate(opt, ...
  %                             'outputPath', outputPath, ...
  %                             'pipelineType', pipelineType, ...
  %                             'partialsPath', partialsPath, ...
  %                             'verbose', true)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :param outputPath:
  % :type outputPath: char
  %
  % :param pipelineType:
  % :type pipelineType: char
  %
  % :param partialsPath:
  % :type partialsPath: path
  %
  % :param verbose:
  % :type verbose: boolean
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  defaultPartialsPath = fullfile(fileparts(mfilename('fullpath')), 'partials');

  args = inputParser;

  args.addRequired('opt', @isstruct);
  args.addParameter('outputPath', '', @ischar);
  args.addParameter('pipelineType', 'spatial_preproc', @ischar);
  args.addParameter('partialsPath', defaultPartialsPath, @isdir);
  args.addParameter('verbose', true, @islogical);

  args.parse(varargin{:});

  opt = args.Results.opt;
  outputPath = args.Results.outputPath;
  pipelineType = args.Results.pipelineType;
  partialsPath = args.Results.partialsPath;
  verbose = args.Results.verbose;

  %% get info
  [OS, generatedBy] = getEnvInfo(opt);
  opt.OS = OS;
  opt.generatedBy = generatedBy;

  if strcmp(OS.name, 'GLNXA64')
    opt.OS.name = 'unix';
  end

  if strcmp(pipelineType, 'spatial_preproc')

    opt.normalization = false;
    if ismember('IXI549Space', opt.space)
      opt.normalization = true;
    end

    opt.unwarp = false;
    if opt.realign.useUnwarp
      opt.unwarp = true;
    end

    opt.smoothing = true;
    if opt.fwhm.func == 0
      opt.smoothing = false;
    end

  elseif strcmp(pipelineType, 'stats')

    opt.smoothing = true;
    if opt.fwhm.contrast == 0
      opt.smoothing = false;
    end

    bm = BidsModel('file', opt.model.file);

    opt.taskName = bm.Input.task;

    if isfield(bm.Input, 'space')
      opt.space = bm.Input.space;
    end

    opt.HighPassFilterCutoffSecs = bm.getHighPassFilter();

    variablesToConvolve = bm.getVariablesToConvolve();
    if iscell(variablesToConvolve)
      % try to let octache deals with this.
      variablesToConvolve = strjoin(variablesToConvolve, ', ');
      variablesToConvolve = regexprep(variablesToConvolve, 'trial_type.', '');
    end
    opt.variablesToConvolve = variablesToConvolve;

    opt.SerialCorrelationCorrection = bm.getSerialCorrelationCorrection;
    opt.FAST = false;
    if strcmpi(opt.SerialCorrelationCorrection, 'fast')
      opt.FAST = true;
    end

    derivatives = bm.getHRFderivatives();
    if any(derivatives)
      if all(derivatives == [1 0])
        opt.derivatives.type = 'temporal';
      elseif all(derivatives == [1 1])
        opt.derivatives.type = 'temporal and dispersion';
      end
    else
      opt.derivatives = false;
    end

  end

  %% render
  if strcmp(pipelineType, 'spatial_preproc')
    fileToRender = fullfile(fileparts(mfilename('fullpath')), 'boilerplate_preprocess.mustache');

  elseif strcmp(pipelineType, 'stats')
    fileToRender = fullfile(fileparts(mfilename('fullpath')), 'boilerplate_stats.mustache');

  end

  output = octache(fileToRender, ...
                   'data', opt, ...
                   'partials_path', partialsPath, ...
                   'partials_ext', 'mustache', ...
                   'l_del', '{{', ...
                   'r_del', '}}', ...
                   'warn', true, ...
                   'keep', true);

  % hack because octache may sometimes return cells and not arrays
  % if something in the data is a cell
  if iscell(output)
    output = strjoin(output);
  end

  %% print to screen
  if verbose
    printToScreen(output);
  end

  %% print to file
  if ~isempty(outputPath)

    spm_mkdir(outputPath);

    if strcmp(pipelineType, 'spatial_preproc')
      outputFile = 'preprocess.md';
    elseif strcmp(pipelineType, 'stats')
      outputFile = 'stats.md';
    end

    outputFile = fullfile(outputPath, outputFile);

    fid = fopen(outputFile, 'wt');
    if fid == -1
      error('Unable to open file "%s" for writing.', filename);
    end
    fprintf(fid, '%s', output);
    fclose(fid);

  end

end

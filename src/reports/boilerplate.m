function outputFile = boilerplate(varargin)
  %
  % USAGE::
  %
  %     outputFile = boilerplate(opt, ...
  %                             'outputPath', outputPath, ...
  %                             'pipelineType', pipelineType, ...
  %                             'partialsPath', partialsPath, ...
  %                             'verbosity', 2)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param outputPath:
  % :type outputPath: char
  %
  % :param pipelineType: ``'preprocess'``, ``'stats'``, ``'create_roi'``
  % :type pipelineType: char
  %
  % :param partialsPath:
  % :type partialsPath: path
  %
  % :param verbose:
  % :type verbose: boolean
  %
  %
  % EXAMPLE::
  %
  %   opt.model.file = path_to_model;
  %   opt.designType = 'event';
  %   opt = checkOptions(opt);
  %
  %   outputFile = boilerplate(opt, ...
  %                             'outputPath', pwd, ...
  %                             'pipelineType', 'stats', ...
  %                             'verbosity', 2)
  %
  %

  % (C) Copyright 2022 bidspm developers

  ALLOWED_BOILERPLATES = sort({'preprocess', 'stats', 'create_roi'});

  defaultPartialsPath = fullfile(returnRootDir(), 'src', 'reports', 'partials');

  isFolder = @(x) isdir(x);

  args = inputParser;

  args.addRequired('opt', @isstruct);
  args.addParameter('outputPath', '', @ischar);
  args.addParameter('pipelineType', 'preproc', @ischar);
  args.addParameter('partialsPath', defaultPartialsPath, isFolder);
  args.addParameter('verbosity', 2);

  args.parse(varargin{:});

  opt = args.Results.opt;
  outputPath = args.Results.outputPath;
  pipelineType = lower(args.Results.pipelineType);
  partialsPath = args.Results.partialsPath;
  opt.verbosity = args.Results.verbosity;

  %% get info
  [OS, generatedBy] = getEnvInfo(opt);
  opt.OS = OS;
  opt.generatedBy = generatedBy;

  if strcmp(OS.name, 'GLNXA64')
    opt.OS.name = 'unix';
  end

  copyBibFile(outputPath);

  extra = '';
  fileToRender = sprintf('boilerplate_%s.mustache', pipelineType);

  switch pipelineType

    case 'preprocess'

      if opt.dummy_scans == 0
        opt.dummy_scans = false;
      else
        opt.dummy_scans = struct('nb', opt.dummy_scans);
      end

      opt.normalization = false;
      if ismember('IXI549Space', opt.space)
        opt.normalization = true;
      end

      opt.unwarp = false;
      if opt.realign.useUnwarp
        opt.unwarp = true;
      end

      opt.smoothing = opt.fwhm.func > 0;

    case 'stats'

      opt.smoothing = opt.fwhm.contrast > 0;
      if opt.smoothing
        opt.fwhm.cumulative = computeCumulativeFwhm(opt);
      end

      bm = BidsModel('file', opt.model.file);

      opt.taskName = strjoin(bm.Input.task, ', ');

      if isfield(bm.Input, 'space')
        opt.space = bm.Input.space;
      end

      opt.HighPassFilterCutoffSecs = round(bm.getHighPassFilter());

      opt.SerialCorrelationCorrection = bm.getSerialCorrelationCorrection;
      opt.FAST = false;
      if strcmpi(opt.SerialCorrelationCorrection, 'fast')
        opt.FAST = true;
      end

      opt = setConvolve(opt, bm);

      opt = setDerivatives(opt, bm);

      opt = setConfounds(opt, bm);

      opt.group_level = false;
      if ~isempty(bm.get_nodes('Level', 'dataset'))

        contrasts = genList('name', getDummyContrastsList('dataset_level', bm));

        opt.group_level = struct('contrasts', {contrasts});

      end

      opt.roi_based = false;
      if opt.glm.roibased.do
        opt.roi_based = true;
        opt.smoothing = false;
        opt.group_level = false;
      end

      extra = bm.Name;

    case 'create_roi'
      opt.atlas = lower(opt.roi.atlas);

      switch opt.atlas
        case 'glasser'
          opt.reference = '[glasser2016]';
        case 'hcpex'
          opt.reference = '[huang2022]';
        case 'wang'
          opt.reference = '[wang2014]';
        case 'visfatlas'
          opt.reference = '[rosenke2020]';
        otherwise
          opt.reference = '';
      end

      opt.roi = genList('name', opt.roi.name);

      extra = opt.atlas;

    otherwise
      msg = sprintf(['Unknown boilerplate requested. Got: "%s".\n', ...
                     'Allowed boilerplates are: %s'], ...
                    pipelineType, ...
                    bids.internal.create_unordered_list(ALLOWED_BOILERPLATES));

      logger('ERROR', msg, ...
             'options', opt, ...
             'filename', mfilename, 'id', 'unknownBoilerplateType');

  end

  %% render
  output = octache(fullfile(fileparts(mfilename('fullpath')), fileToRender), ...
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

  %% print to file
  outputFile = printToFile(output, outputPath, pipelineType, extra);

  %% print to screen
  logger('INFO', sprintf('methods boilerplate saved at:\n\t%s\n', outputFile), ...
         'options', opt, ...
         'filename', mfilename());

end

function list = genList(name, elements)

  list = '';

  if ~isempty(elements) && iscell(elements)
    for i = 1:numel(elements)
      list{i} = struct(name, elements{i});
    end
  end

end

function opt = setConfounds(opt, bm)

  opt.confounds = false;

  rootNode = bm.get_root_node();
  designMatrix = rootNode.Model.X;
  designMatrix = removeIntercept(designMatrix);

  variablesToConvolve = bm.getVariablesToConvolve();

  confoundsIdx = ~ismember(designMatrix, variablesToConvolve);
  if sum(confoundsIdx) > 0

    confounds = struct('motion', false, ...
                       'tissue', false, ...
                       'scrubbing', false);

    confoundsNames = designMatrix(confoundsIdx);

    motionRegressorRegexp = '^(rot)|(trans)|(std_dvars)|(dvars)|(framewise_displacement).*';
    isMotionRegressor = ~cellfun('isempty', regexp(confoundsNames, ...
                                                   motionRegressorRegexp, ...
                                                   'match'));
    if any(isMotionRegressor)
      confounds.motion = true;
    end

    isTissueRegressor = ~cellfun('isempty', regexp(confoundsNames, ...
                                                   '^(csf)|(white_matter)|(global_signal).*', ...
                                                   'match'));
    if any(isTissueRegressor)
      confounds.tissue = true;
    end

    isOutlier = ~cellfun('isempty', regexp(confoundsNames, ...
                                           '^.*outlier.*$', ...
                                           'match'));
    if any(isOutlier)
      confounds.scrubbing = true;
    end

    confounds.variables = genList('name', confoundsNames);

    opt.confounds = confounds;
  end

end

function opt = setConvolve(opt, bm)

  opt.convolve = false;

  variablesToConvolve = bm.getVariablesToConvolve();

  variablesToConvolve = regexprep(variablesToConvolve, 'trial_type.', '');

  opt.convolve = genList('variablesToConvolve', variablesToConvolve);

end

function opt = setDerivatives(opt, bm)

  opt.derivatives = false;

  derivatives = bm.getHRFderivatives();

  if any(derivatives)
    if all(derivatives == [1 0])
      derivatives = struct('type', 'temporal');
      opt.derivatives = derivatives;
    elseif all(derivatives == [1 1])
      derivatives = struct('type', 'temporal and dispersion');
      opt.derivatives = derivatives;
    end

  end
end

function copyBibFile(outputPath)
  bibFile = fullfile(returnRootDir(), 'src', 'reports', 'bidspm.bib');
  spm_mkdir(outputPath);
  copyfile(bibFile, outputPath);
end

function outputFile = printToFile(output, outputPath, pipelineType, extra)

  outputFile = '';

  if nargin < 4
    extra = '';
  end

  if ~isempty(outputPath)

    sts = spm_mkdir(spm_file(outputPath, 'cpath'));
    if sts == 0
      error('Unable to create folder:\n\t%s', outputPath);
    end

    switch pipelineType
      case 'stats'
        extra = ['model-' extra '_'];
      case 'create_roi'
        extra = ['atlas-' extra '_'];
    end

    outputFile = [pipelineType '_' extra 'citation.md'];

    outputFile = fullfile(outputPath, outputFile);

    fid = fopen(outputFile, 'wt');
    if fid == -1
      error(['Unable to open file "%s" for writing.', ...
             '\nIf you are using a datalad dataset, make sure the file is unlocked.'], ...
            bids.internal.file_utils(outputFile, 'cpath'));
    end
    fprintf(fid, '%s', output);
    fclose(fid);

  end

end

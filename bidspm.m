function returnCode = bidspm(varargin)
  %
  % Type bidspm('action', 'help') for more information.
  %

  % (C) Copyright 2022 bidspm developers

  args = defaultInputParser();

  %   isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>
  %   isFileOrStruct = @(x) isstruct(x) || exist(x, 'file') == 2;
  %   isLogical = @(x) islogical(x) && numel(x) == 1;
  %   isChar = @(x) ischar(x);
  %   isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  %   isFolder = @(x) isdir(x);
  %   isCellStr = @(x) iscellstr(x);
  %   isInAvailableAtlas = @(x) (ischar(x) && ismember(x, supportedAtlases()));

  %   addParameter(args, 'dry_run', false, isLogical);
  %   addParameter(args, 'skip_validation', false, isLogical);
  %   addParameter(args, 'boilerplate_only', false, isLogical);
  %
  %   addParameter(args, 'fwhm', 6, isPositiveScalar);
  %
  %
  %   % preproc only
  %   addParameter(args, 'dummy_scans', 0, isPositiveScalar);
  %   addParameter(args, 'anat_only', false, isLogical);
  %   addParameter(args, 'ignore', {}, isEmptyOrCellstr);
  %
  %   % stats only
  %   addParameter(args, 'preproc_dir', pwd, isFolder);
  %   addParameter(args, 'model_file', struct([]), isFileOrStruct);
  %   addParameter(args, 'roi_based', false, isLogical);
  %   addParameter(args, 'design_only', false, isLogical);
  %   addParameter(args, 'concatenate', false, isLogical);
  %   addParameter(args, 'keep_residuals', false, isLogical);
  %
  %   % group level stats only
  %   addParameter(args, 'node_name', '', isChar);

  parse(args, varargin{:});

  action = args.Results.action;

  % to simplify the API, user can call things like ``bidspm help``
  % or ``bidspm init`` but then this needs to override the action value.
  bidsDir = args.Results.bids_dir;
  if ismember(bidsDir, lowLevelActions())
    action = bidsDir;
  end

  try
    returnCode = executeAction(action, varargin{:});
  catch ME
    opt.dir.output = args.Results.output_dir;
    opt.dryRun = false;
    opt.verbosity = 3;
    if isempty(which('bugReport'))
      rethrow(ME);
    else
      bugReport(opt, ME);
    end
    returnCode = 1;
  end
end

function returnCode = executeAction(varargin)

  returnCode = 0;

  action = varargin{1};

  switch lower(action)

    case 'init'
      initBidspm();

    case 'help'
      system('bidspm --help');
      help(fullfile(fileparts(mfilename('fullpath')), 'src', 'messages', 'bidspmHelp.m'));

    case 'version'
      versionBidspm();

    case 'dev'
      initBidspm(true);

    case 'uninit'
      uninitBidspm();

    case 'update'
      update();

    case 'run_tests'
      returnCode = run_tests();

    case 'copy'
      cliCopy(varargin{2:end});

    case 'create_roi'
      cliCreateRoi(varargin{2:end});

    case 'smooth'
      cliSmooth(varargin{2:end});

    case 'preprocess'
      validate(args);
      if ~strcmp(args.Results.analysis_level, 'subject')
        errorHandling(mfilename(), ...
                      'noGroupLevelPreproc', ...
                      '"analysis_level" must be "subject" for preprocessing', ...
                      false);
      end
      preprocess(args);

    case 'default_model'
      cliDefaultModel(varargin{2:end});

    case {'stats', 'contrasts', 'results'}
      validate(args);
      stats(args);

    case 'meaning_of_life'
      fprintf('\n42\n\n');

    otherwise
      errorStruct.identifier = 'bidspm:unknownAction';
      errorStruct.message = sprintf('action %s is not among the known actions:\n\t- %s', ...
                                    action, ...
                                    strjoin(allowedActions(), '\n\t- '));
      error(errorStruct);

  end

end

%% high level actions

function preprocess(args)
  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  opt = getOptionsFromCliArgument(args);

  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);

  if opt.anatOnly
    opt.query.modality = 'anat';
  end

  if ~opt.anatOnly && (isempty(opt.taskName) || numel(opt.taskName) > 1)
    errorHandling(mfilename(), ...
                  'onlyOneTaskForPreproc', ...
                  'A single task must be specified for preprocessing', ...
                  false);
  end

  saveOptions(opt);

  bidsReport(opt);
  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.output, 'reports'), ...
              'pipelineType', 'preprocess', ...
              'verbosity', 0);
  if opt.boilerplate_only
    return
  end
  bidsCopyInputFolder(opt);
  if opt.dummy_scans > 0
    tmpOpt = opt;
    tmpOpt.dir.input = tmpOpt.dir.preproc;
    bidsRemoveDummies(tmpOpt, ...
                      'dummyScans', tmpOpt.dummy_scans, ...
                      'force', false);
  end
  bidsCheckVoxelSize(opt);
  if opt.useFieldmaps && ~opt.anatOnly
    bidsCreateVDM(opt);
  end
  if ~opt.stc.skip && ~opt.anatOnly
    bidsSTC(opt);
  end
  bidsSpatialPrepro(opt);
  if opt.fwhm.func > 0 && ~opt.anatOnly
    opt.query.desc = 'preproc';
    if opt.dryRun
      msg = ['"dryRun" set to "true", so smoothing will be skipped', ...
             ' as it requires the output of spatial preprocessing to run.'];
      logger('WARNING', msg, ...
             'options', opt, ...
             'filename', mfilename(), ...
             'id', 'skipSmoothingInDryRun');
      return
    end
    bidsSmoothing(opt);
  end

end

function stats(args)

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  opt = getOptionsFromCliArgument(args);

  if opt.glm.roibased.do
    opt.bidsFilterFile.roi.space = opt.space;
    opt.bidsFilterFile.roi.label = opt.roi.name;
  end

  opt.pipeline.type = 'stats';
  opt = checkOptions(opt);

  action = args.Results.action;
  analysisLevel = args.Results.analysis_level;
  nodeName = args.Results.node_name;
  concatenate = args.Results.concatenate;

  isSubjectLevel = strcmp(analysisLevel, 'subject');
  estimate = strcmp(action, 'stats');
  contrasts = ismember(action, {'stats', 'contrasts'});
  results = ismember(action, {'stats', 'contrasts', 'results'});

  if opt.model.designOnly
    contrasts = false;
    results = false;
  end

  saveOptions(opt);

  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.output, 'reports'), ...
              'pipelineType', 'stats', ...
              'verbosity', 0);
  if opt.boilerplate_only
    return
  end

  if opt.glm.roibased.do

    bidsFFX('specify', opt);
    if ~opt.model.designOnly
      bidsRoiBasedGLM(opt);
    end

  else

    if estimate

      if isSubjectLevel
        if opt.model.designOnly
          bidsFFX('specify', opt);
        else
          bidsFFX('specifyAndEstimate', opt);
        end

      else
        if opt.fwhm.contrast > 0
          bidsSmoothContrasts(opt);
        end
        bidsRFX('RFX', opt, 'nodeName', nodeName);

      end

    end

    if contrasts
      if isSubjectLevel
        bidsFFX('contrasts', opt);
      else
        bidsRFX('contrasts', opt, 'nodeName', nodeName);
      end

      if isSubjectLevel && concatenate
        bidsConcatBetaTmaps(opt);
      end

    end

    if results
      bidsResults(opt, 'nodeName', nodeName);
    end

  end

end

%% low level actions

function versionBidspm()
  try
    versionNumber = getVersion();
  catch
    versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), 'version.txt'));
    versionNumber = versionNumber(1:end - 1);
  end
  fprintf(1, '%s\n', versionNumber);
end

function initBidspm(dev)
  %
  % Adds the relevant folders to the path for a given session.
  % Has to be run to be able to use bidspm.
  %
  % USAGE::
  %
  %   initBidspm()
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 1
    dev = false;
  end

  opt.verbosity = 2;
  opt.msg.color = '';

  octaveVersion = '6.4.0';
  matlabVersion = '8.6.0';

  % octave packages
  installlist = {'io', 'statistics', 'image'};

  thisDirectory = fileparts(mfilename('fullpath'));

  global BIDSPM_INITIALIZED
  global BIDSPM_PATHS

  if isempty(BIDSPM_INITIALIZED)

    pathSep = ':';
    if ~isunix
      pathSep = ';';
    end

    % add bidspm source code
    BIDSPM_PATHS = fullfile(thisDirectory);
    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
                       pathSep, ...
                       genpath(fullfile(thisDirectory, 'src')));
    if dev
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                         fullfile(thisDirectory, 'tests', 'utils'));
    end

    % for some reasons this folder was otherwise not added to the path in Octave
    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
                       pathSep, ...
                       genpath(fullfile(thisDirectory, 'src', 'workflows', 'stats')));

    % add library that do not have an set up script
    libList = {'spmup'};

    for i = 1:numel(libList)
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
                         pathSep, ...
                         genpath(fullfile(thisDirectory, 'lib', libList{i})));
    end

    libList = {'mancoreg', ...
               'bids-matlab', ...
               'slice_display', ...
               'panel-2.14', ...
               'utils'};
    for i = 1:numel(libList)
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                         fullfile(thisDirectory, 'lib', libList{i}));
    end

    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                       fullfile(thisDirectory, 'lib', 'brain_colours', 'code'));

    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                       fullfile(thisDirectory, 'lib', 'riksneurotools', 'GLM'));

    addpath(BIDSPM_PATHS, '-begin');

    silenceOctaveWarning();

    % add library that have a set up script
    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'initCppRoi'));
    run(fullfile(thisDirectory, 'lib', 'spm_2_bids', 'init_spm_2_bids'));
    run(fullfile(thisDirectory, 'lib', 'octache', 'setup'));

    checkDependencies(opt);
    printCredits(opt);

    %%
    if bids.internal.is_octave()

      % Exit if min version is not satisfied
      if ~compare_versions(OCTAVE_VERSION, octaveVersion, '>=')
        error('Minimum required Octave version: %s', octaveVersion);
      end

      for ii = 1:length(installlist)

        packageName = installlist{ii};

        try
          % Try loading Octave packages
          printToScreen(['loading ' packageName '\n']);
          pkg('load', packageName);

        catch

          tryInstallFromForge(packageName);

        end
      end

    else % MATLAB ----------------------------

      if verLessThan('matlab', matlabVersion)
        error('Sorry, minimum required MATLAB version is R2015b. :(');
      end

    end

    BIDSPM_INITIALIZED = true();

    detectBidspm();

  else
    logger('INFO', 'bidspm already initialized');

  end

end

function uninitBidspm()
  %
  % Removes the added folders from the path for a given session.
  %
  % USAGE::
  %
  %   uninitBidspm()
  %

  % (C) Copyright 2021 bidspm developers

  thisDirectory = fileparts(mfilename('fullpath'));

  global BIDSPM_INITIALIZED
  global BIDSPM_PATHS

  if isempty(BIDSPM_INITIALIZED) || ~BIDSPM_INITIALIZED
    fprintf('\n\nbidspm not initialized\n\n');
    return

  else
    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'uninitCppRoi'));
    rmpath(BIDSPM_PATHS);
    spm('Clean');
    spm('Quit');

    if isOctave()
      clear -g;
    else
      clearvars -GLOBAL;
    end

  end

end

function returnCode = run_tests()
  %

  % (C) Copyright 2019 bidspm developers

  % Elapsed time is 284 seconds.

  tic;

  bidspm('action', 'dev');

  % to reduce noise in the output
  silenceOctaveWarning();

  cd(fileparts(mfilename('fullpath')));

  if bids.internal.is_github_ci()
    logger('INFO', 'This is github CI');
  else
    logger('INFO', 'This is not github CI');
  end

  logger('INFO', sprintf('Home is "%s"\n', getenv('HOME')));

  warning('OFF');

  spm('defaults', 'fMRI');

  subfolder = '';

  folderToCover = fullfile(pwd, 'src');
  testFolder = fullfile(pwd, 'tests', subfolder);

  returnCode = moxunit_runtests(testFolder, ...
                                '-verbose', '-recursive', '-randomize_order', ...
                                '-with_coverage', ...
                                '-cover', folderToCover, ...
                                '-cover_xml_file', 'coverage.xml', ...
                                '-cover_html_dir', fullfile(pwd, 'coverage_html'));

  toc;

end

function update()
  try
    initBidspm();
    cwd = pwd();
    cd(returnRootDir());
    system('make update');
    cd(cwd);
  catch ME
    warning('Could not run the update.');
    rethrow(ME);
  end
end

%% constants

function value = lowLevelActions()
  value = {'init'; ...
           'uninit'; ...
           'dev'
           'version'; ...
           'run_tests'; ...
           'update'; ...
           'help'; ...
           'meaning_of_life'};
end

function value = bidsAppsActions()

  value = {'copy'; ...
           'create_roi'; ...
           'preprocess'; ...
           'smooth'; ...
           'default_model'; ...
           'stats'; ...
           'contrasts'; ...
           'results'};

end

function value = allowedActions()

  value = cat(1, bidsAppsActions(), lowLevelActions());

end

%% input parsers
function args = defaultInputParser()

  args = inputParser;
  args.CaseSensitive = false;
  args.KeepUnmatched = true;
  args.FunctionName = 'bidspm';

  defaultAction = 'init';

  isLowLevelActionOrDir = @(x) (ismember(x, lowLevelActions()) || isdir(x));
  isChar = @(x) ischar(x);

  addOptional(args, 'bids_dir', pwd, isLowLevelActionOrDir);
  addOptional(args, 'output_dir', '', isChar);
  addOptional(args, 'analysis_level', 'subject', @(x) ismember(x, {'subject', 'dataset'}));
  addParameter(args, 'action', defaultAction, isChar);

end

%% helpers functions
function detectBidspm()

  workflowsDir = cellstr(which('bidsSpatialPrepro.m', '-ALL'));

  if isempty(workflowsDir)
    error('bidspm is not in your MATLAB / Octave path.\n');

  elseif numel(workflowsDir) > 1
    printToScreen('bidspm seems to appear in several different folders:');
    for i = 1:numel(workflowsDir)
      fprintf('  * %s\n', fullfile(workflowsDir{i}, '..', '..'));
    end
    error('Remove all but one with ''pathtool''.\n'); % or ''spm_rmpath

  end
end

function tryInstallFromForge(packageName)

  errorcount = 1;
  while errorcount % Attempt twice in case installation fails
    try
      pkg('install', '-forge', packageName);
      pkg('load', packageName);
      errorcount = 0;
    catch err
      errorcount = errorcount + 1;
      if errorcount > 2
        error(err.message);
      end
    end
  end

end

function retval = isOctave()
  persistent cacheval   % speeds up repeated calls
  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end

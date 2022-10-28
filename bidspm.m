function bidspm(varargin)
  %
  % Type bidspm('action', 'help') for more information.
  %

  % (C) Copyright 2022 bidspm developers

  % TODO  bidspm('action', 'update')
  % TODO  where to save the options?

  args = inputParser;
  args.CaseSensitive = false;

  defaultAction = 'init';

  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);
  isFileOrStruct = @(x) isstruct(x) || exist(x, 'file') == 2;

  isLogical = @(x) islogial(x) && numel(x) == 1;
  isChar = @(x) ischar(x);
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;

  isDir = @(x) isdir(x);

  isCellStr = @(x) iscellstr(x);

  isLowLevelActionOrDir = @(x) (ismember(x, low_level_actions()) || isdir(x));

  addOptional(args, 'bids_dir', pwd, isLowLevelActionOrDir);

  addOptional(args, 'output_dir', '', isChar);
  addOptional(args, 'analysis_level', 'subject', @(x) ismember(x, {'subject', 'dataset'}));

  addParameter(args, 'action', defaultAction, isChar);
  addParameter(args, 'participant_label', {}, isCellStr);
  addParameter(args, 'task', {}, isCellStr);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'bids_filter_file', struct([]), isFileOrStruct);
  addParameter(args, 'options', struct([]), isFileOrStruct);
  addParameter(args, 'verbosity', 2, isPositiveScalar);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'space', {}, isCellStr);

  % preproc only
  addParameter(args, 'dummy_scans', 0, isPositiveScalar);
  addParameter(args, 'anat_only', false, isLogical);
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);

  % stats only
  addParameter(args, 'preproc_dir', pwd, isDir);
  addParameter(args, 'model_file', struct([]), isFileOrStruct);
  addParameter(args, 'roi_based', false, isLogical);
  % group level stats only
  addParameter(args, 'node_name', '', isChar);

  parse(args, varargin{:});

  action = args.Results.action;

  % to simplify the API, user can call things like ``bidspm help``
  % or ``bidspm init`` but then this needs to override the action value.
  bidsDir = args.Results.bids_dir;
  if ismember(bidsDir, low_level_actions())
    action = bidsDir;
  end

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

      system('make update');

    case 'run_tests'

      run_tests();

    case 'preprocess'

      if ~strcmp(args.Results.analysis_level, 'subject')
        errorHandling(mfilename(), ...
                      'noGroupLevelPreproc', ...
                      '"analysis_level" must be "subject" for preprocessing', ...
                      false);
      end

      preprocess(args);

    case {'stats', 'contrasts', 'results'}

      stats(args);

    case 'meaning_of_life'

      fprintf('\n42\n\n');

    otherwise

      errorStruct.identifier = 'bidspm:unknownAction';
      errorStruct.message = sprintf('action %s is not among the known actions:\n\t- %s', ...
                                    action, ...
                                    strjoin(allowed_actions(), '\n\t- '));
      error(errorStruct);

  end

end

%% "getter"

function opt = get_options_from_argument(args)

  action = args.Results.action;

  if ismember(lower(action), bids_apps_actions)

    bidspm('action', 'init');

    if isstruct(args.Results.options)
      opt = args.Results.options;
    elseif exist(args.Results.options, 'file') == 2
      opt = bids.util.jsondecode(args.Results.options);
    end

    if isempty(opt)
      % set defaults
      opt = checkOptions(struct());
    end

    opt.dir.raw = args.Results.bids_dir;
    opt.dir.derivatives = args.Results.output_dir;

    opt = overrideDryRun(opt, args);

    if ~isempty(args.Results.participant_label)
      opt.subjects = args.Results.participant_label;
    end

    if ~isempty(args.Results.task)
      opt.taskName = args.Results.task;
    end

    if ~isempty(args.Results.bids_filter_file)
      % TODO read from JSON if necessary
      % TODO validate
      opt.bidsFilterFile = args.Results.bids_filter_file;
    end

    opt = overrideFwhm(opt, args);

    opt = overrideSpace(opt, args);

    % preproc
    if ismember('slicetiming', args.Results.ignore)
      opt.stc.skip = true;
    end
    if ismember('unwarp', args.Results.ignore)
      opt.realign.useUnwarp = false;
    end
    if ismember('fieldmaps', args.Results.ignore)
      opt.useFieldmaps = false;
    end
    if ismember('qa', lower(args.Results.ignore))
      opt.QA.func.do = false;
      opt.QA.anat.do = false;
      opt.QA.glm.do = false;
    end

    opt.dummy_scans = args.Results.dummy_scans;

    opt.anatOnly = args.Results.anat_only;

    % stats
    opt.dir.preproc = args.Results.preproc_dir;
    opt.model.file = args.Results.model_file;

    opt = overrideRoiBased(opt, args);

  end

end

function opt = overrideRoiBased(opt, args)
  if isfield(opt, 'glm') && isfield(opt.glm, 'roibased') && ...
      isfield(opt.glm.roibased, 'do') && opt.glm.roibased.do ~= args.Results.roi_based
    overrideWarning('roi_based', convertToString(args.Results.roi_based), ...
                    'glm.roibased.do', convertToString(opt.glm.roibased.do));
  end
  opt.glm.roibased.do = args.Results.roi_based;
end

function opt = overrideDryRun(opt, args)
  if isfield(opt, 'dryRun') && args.Results.dry_run ~= opt.dryRun
    overrideWarning('dry_run', convertToString(args.Results.dry_run), ...
                    'dryRun', convertToString(opt.dryRun));
  end
  opt.dryRun = args.Results.dry_run;
end

function opt = overrideFwhm(opt, args)
  if ~isempty(args.Results.fwhm) && ...
     (isfield(opt, 'fwhm') && isfield(opt.fwhm, 'func')) && ...
     args.Results.fwhm ~= opt.fwhm.func
    overrideWarning('fwhm', convertToString(args.Results.fwhm), ...
                    'fwhm.func', convertToString(opt.fwhm.func));
  end
  opt.fwhm.func = args.Results.fwhm;
end

function opt = overrideSpace(opt, args)
  if ~isempty(args.Results.space)
    if isfield(opt, 'space') && ~all(ismember(args.Results.space, opt.space))
      overrideWarning('space', convertToString(args.Results.space), ...
                      'space', convertToString(opt.space));
    end
    opt.space = args.Results.space;
  end
end

function output = convertToString(input)
  if islogical(input) && input == true
    output = 'true';
  elseif islogical(input) && input == false
    output = 'false';
  elseif isnumeric(input)
    output = num2str(input);
  elseif cellstr(input)
    output = strjoin(input, ', ');
  end
end

function overrideWarning(thisArgument, newValue, thisOption, oldValue)

  msg = sprintf('\nArgument "%s" value "%s" will override option "%s" value "%s".\n', ...
                thisArgument, ...
                newValue, ...
                thisOption, ...
                oldValue);
  errorHandling(mfilename(), 'argumentOverridesOptions', msg, true, true);

end

%% high level actions

function preprocess(args)

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  opt = get_options_from_argument(args);

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

  reportBIDS(opt);
  bidsCopyInputFolder(opt);
  if opt.dummy_scans > 0
    bidsRemoveDummies(opt, ...
                      'dummyScans', opt.dummy_scans, ...
                      'force', false);
  end
  if opt.useFieldmaps && ~opt.anatOnly
    bidsCreateVDM(opt);
  end
  if ~opt.stc.skip && ~opt.anatOnly
    bidsSTC(opt);
  end
  bidsSpatialPrepro(opt);
  if opt.fwhm.func > 0 && ~opt.anatOnly
    bidsSmoothing(opt);
  end

end

function stats(args)

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  opt = get_options_from_argument(args);

  opt.pipeline.type = 'stats';
  opt = checkOptions(opt);

  action = args.Results.action;
  analysisLevel = args.Results.analysis_level;
  nodeName = args.Results.node_name;

  isSubjectLevel = strcmp(analysisLevel, 'subject');
  estimate = strcmp(action, 'stats');
  contrasts = ismember(action, {'stats', 'contrasts'});
  results = ismember(action, {'stats', 'contrasts', 'results'});

  if opt.glm.roibased.do

    bidsFFX('specify', opt);
    bidsRoiBasedGLM(opt);

  else

    if estimate
      if isSubjectLevel
        bidsFFX('specifyAndEstimate', opt);
      else
        bidsRFX('RFX', opt, 'nodeName', nodeName);
      end
    end

    if contrasts
      if isSubjectLevel
        bidsFFX('contrasts', opt);
      else
        bidsRFX('contrasts', opt, 'nodeName', nodeName);
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

  octaveVersion = '4.0.3';
  matlabVersion = '8.6.0';

  % octave packages
  installlist = {};
  % installlist = {'io', 'statistics', 'image'};

  thisDirectory = fileparts(mfilename('fullpath'));

  global BIDSPM_INITIALIZED
  global BIDSPM_PATHS

  if isempty(BIDSPM_INITIALIZED)

    pathSep = ':';
    if ~isunix
      pathSep = ';';
    end

    % add library first and then BIDSpm source code
    % except for current folder
    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'initCppRoi'));
    run(fullfile(thisDirectory, 'lib', 'spm_2_bids', 'init_spm_2_bids'));
    run(fullfile(thisDirectory, 'lib', 'octache', 'setup'));

    % now add BIDSpm source code
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

    % then add library that do not have an set up script
    libList = {'spmup'};

    for i = 1:numel(libList)
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
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

    if isOctave
      warning('off', 'Octave:shadowed-function');
    end

    checkDependencies(opt);
    printCredits(opt);

    %%
    if isOctave

      % Exit if min version is not satisfied
      if ~compare_versions(OCTAVE_VERSION, octaveVersion, '>=')
        error('Minimum required Octave version: %s', octaveVersion);
      end

      for ii = 1:length(installlist)

        packageName = installlist{ii};

        try
          % Try loading Octave packages
          printToScreen(['loading ' packageName]);
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
    printToScreen('\n\nbidspm already initialized\n\n');

  end

end

function uninitBidspm()
  %
  % Removes the added folders fromthe path for a given session.
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

    try
      % this might not work on octave
      clearvars -GLOBAL;
    catch
    end

  end

end

function run_tests()
  %

  % (C) Copyright 2019 bidspm developers

  % Elapsed time is 284 seconds.

  tic;

  bidspm('action', 'dev');

  cd(fileparts(mfilename('fullpath')));

  if isGithubCi
    printToScreen('\nThis is github CI\n');
  else
    printToScreen('\nThis is not github CI\n');
  end

  printToScreen(sprintf('\nHome is %s\n', getenv('HOME')));

  warning('OFF');

  spm('defaults', 'fMRI');

  subfolder = '';

  folderToCover = fullfile(pwd, 'src');
  testFolder = fullfile(pwd, 'tests', subfolder);

  success = moxunit_runtests( ...
                             testFolder, ...
                             '-verbose', '-recursive', '-with_coverage', ...
                             '-cover', folderToCover, ...
                             '-cover_xml_file', 'coverage.xml', ...
                             '-cover_html_dir', fullfile(pwd, 'coverage_html'));

  if success
    system('echo 0 > test_report.log');
  else
    system('echo 1 > test_report.log');
  end

  toc;

end

%% constants

function value = bids_apps_actions()

  value = {'preprocess'; 'stats'; 'contrasts'; 'results'};

end

function value = low_level_actions()
  value = {'init'; ...
           'uninit'; ...
           'dev'
           'version'; ...
           'run_tests'; ...
           'update'; ...
           'help'; ...
           'meaning_of_life'};
end

function value = allowed_actions()

  value = cat(1, bids_apps_actions(), low_level_actions());

end

%% helpers functions

function detectBidspm()

  workflowsDir = cellstr(which('bidsSpatialPrepro.m', '-ALL'));

  if isempty(workflowsDir)
    error('bidspm is not in your MATLAB / Octave path.\n');

  elseif numel(workflowsDir) > 1
    printToScreen('bidspm seems to appear in several different folders:\n');
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

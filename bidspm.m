function returnCode = bidspm(varargin)
  %
  % Type bidspm('action', 'help') for more information.
  %

  % (C) Copyright 2022 bidspm developers

  args = defaultInputParser();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

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
    rethrow(ME);
  end
end

function returnCode = executeAction(varargin)

  action = varargin{1};

  returnCode = 0;

  switch lower(action)

    case 'init'
      initBidspm();

    case 'help'
      system('bidspm --help');
      help(fullfile(rootDir(), 'src', 'messages', 'bidspmHelp.m'));

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
      cliPreprocess(varargin{2:end});

    case 'default_model'
      cliDefaultModel(varargin{2:end});

    case {'stats', 'contrasts', 'results', 'specify_only'}
      cliStats(varargin{2:end});

    case {'bms', 'bms-posterior', 'bms-bms'}
      cliBayesModel(varargin{2:end});

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

function displayArguments(varargin)
  disp('arguments passed were :');
  for i = 1:numel(varargin)
    fprintf('- ');
    disp(varargin{i});
  end
  fprintf(1, '\n');
end

function value = rootDir()
  value = fullfile(fileparts(mfilename('fullpath')));
end

%% low level actions
function versionBidspm()
  try
    versionNumber = getVersion();
  catch
    versionNumber = fileread(rootDir(), 'version.txt');
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

  global BIDSPM_INITIALIZED
  global BIDSPM_PATHS

  if isempty(BIDSPM_INITIALIZED)

    pathSep = ':';
    if ~isunix
      pathSep = ';';
    end

    % add bidspm source code
    BIDSPM_PATHS = fullfile(rootDir());
    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
                       pathSep, ...
                       genpath(fullfile(rootDir(), 'src')));
    if dev
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                         fullfile(rootDir(), 'tests', 'utils'));
    end

    % Make sure MACS toolbox used by SPM is the one from bidspm
    updateMacstoolbox();

    % for some reasons this folder was otherwise not added to the path in Octave
    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, ...
                       pathSep, ...
                       genpath(fullfile(rootDir(), 'src', 'workflows', 'stats')));

    libList = {'mancoreg', ...
               'bids-matlab', ...
               'slice_display', ...
               'panel-2.14', ...
               'utils'};
    for i = 1:numel(libList)
      BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                         fullfile(rootDir(), 'lib', libList{i}));
    end

    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                       fullfile(rootDir(), 'lib', 'brain_colours', 'code'));

    BIDSPM_PATHS = cat(2, BIDSPM_PATHS, pathSep, ...
                       fullfile(rootDir(), 'lib', 'riksneurotools', 'GLM'));

    addpath(BIDSPM_PATHS, '-begin');

    silenceOctaveWarning();

    % add library that have a set up script
    run(fullfile(rootDir(), 'lib', 'CPP_ROI', 'initCppRoi'));
    run(fullfile(rootDir(), 'lib', 'spm_2_bids', 'init_spm_2_bids'));
    run(fullfile(rootDir(), 'lib', 'octache', 'setup'));

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

function updateMacstoolbox()

  SPM_DIR = spm('dir');
  target_dir = fullfile(SPM_DIR, 'toolbox', 'MACS');
  MACS_TOOLBOX_DIR = fullfile(rootDir(), 'lib', 'MACS');

  if exist(target_dir, 'dir') == 7 && exist(fullfile(target_dir, '.git'), 'dir') == 0
    rmdir(target_dir, 's');
  end

  if exist(target_dir, 'dir') == 7
    msg = sprintf('updating MACS toolbox: ');
    fprintf(1, msg);
    [status, cmdout] = system(sprintf('git -C %s pull', target_dir));
    if status ~= 0
      fprintf(1, 'Failed to update MACS toolbox: %s\n', cmdout);
    end

  else
    msg = sprintf('installing MACS toolbox in:\n%s.\n', target_dir);
    fprintf(1, msg);
    system(sprintf('git clone %s %s', ...
                   MACS_TOOLBOX_DIR, ...
                   target_dir));
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

  global BIDSPM_INITIALIZED
  global BIDSPM_PATHS

  if isempty(BIDSPM_INITIALIZED) || ~BIDSPM_INITIALIZED
    fprintf('\n\nbidspm not initialized\n\n');
    return

  else
    run(fullfile(rootDir(), 'lib', 'CPP_ROI', 'uninitCppRoi'));
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

  folderToCover = fullfile(pwd, 'src');

  subfolder = '';
  if usingSlowTestMode()
    fprintf(1, 'Running in slow tests only.\n');
    subfolder = 'tests_slow';
  end
  testFolder = fullfile(pwd, 'tests', subfolder);

  generateLayoutMat();

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
           'results'; ...
           'specify_only', ...
           'bms'; ...
           'bms-posterior'; ...
           'bms-bms'};

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

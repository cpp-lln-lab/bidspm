function cpp_spm(varargin)
  %
  % Type cpp_spm('action', 'help') for more information.
  %
  % (C) Copyright 2022 CPP_SPM developers

  % TODO  cpp_spm('action', 'update')
  % TODO  where to save the options?

  args = inputParser;

  defaultAction = 'init';

  isFileOrStruct = @(x) exist(x, 'file') == 2 || isstruct(x);
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;

  addOptional(args, 'bids_dir', pwd, @isdir);
  addOptional(args, 'output_dir', '', @ischar);
  addOptional(args, 'analysis_level', '', @ischar);

  addParameter(args, 'action', defaultAction, @ischar);
  addParameter(args, 'participant_label', {}, @iscellstr);
  addParameter(args, 'task', {}, @iscellstr);
  addParameter(args, 'dry_run', false, @islogical);
  addParameter(args, 'bids_filter_file', struct([]), isFileOrStruct);
  addParameter(args, 'options', struct([]));
  addParameter(args, 'verbosity', 2, isPositiveScalar);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'space', {'individual', 'IXI549Space'}, @iscellstr);

  % preproc only
  addParameter(args, 'dummy_scans', 0, isPositiveScalar);
  addParameter(args, 'anat_only', false, @islogical);
  addParameter(args, 'ignore', {}, @iscellstr);

  % stats only
  addParameter(args, 'preproc_dir', pwd, @isdir);
  addParameter(args, 'model_file', struct([]), isFileOrStruct);
  addParameter(args, 'roi_based', false, @islogical);

  parse(args, varargin{:});

  action = args.Results.action;

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  opt = get_options_from_argument(args);

  switch lower(action)

    case 'init'

      initCppSpm();

    case 'help'

      help(fullfile(fileparts(mfilename('fullpath')), 'src', 'messages', 'cppSpmHelp.m'));

    case 'version'

      try
        versionNumber = getVersion();
      catch
        versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), 'version.txt'));
        versionNumber = versionNumber(1:end - 1);
      end
      fprintf(1, '%s\n', versionNumber);

    case 'dev'

      initCppSpm(true);

    case 'uninit'

      uninitCppSpm();

    case 'run_tests'

      run_tests();

    case 'preprocess'

      if ~strcmp(args.Results.analysis_level, 'participant')
        errorHandling(mfilename(), ...
                      'noGroupLevelPreproc', ...
                      '"analysis_level" must be "participant" for preprocessing', ...
                      false);
      end

      opt.pipeline.type = 'preproc';
      opt = checkOptions(opt);

      preprocess(opt);

    case 'stats'

      opt.pipeline.type = 'stats';
      opt = checkOptions(opt);

      stats(opt);

    otherwise

      errorStruct.identifier = 'cpp_spm:unknownAction';
      errorStruct.message = sprintf('action %s is not among the knonw actions:\n\t- %s', ...
                                    action, ...
                                    strjoin(allowed_actions(), '\n\t- '));
      error(errorStruct);

  end

end

%% "getter"

function opt = get_options_from_argument(args)

  action = args.Results.action;

  opt = args.Results.options;

  if ismember(lower(action), bids_apps_actions)

    cpp_spm('action', 'init');

    if isempty(opt)
      % set defaults
      opt = checkOptions(struct());
    end

    opt.dir.raw = args.Results.bids_dir;
    opt.dir.derivatives = args.Results.output_dir;

    opt.dryRun = args.Results.dry_run;

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

    opt.fwhm.func = args.Results.fwhm;

    if ~isempty(args.Results.space)
      opt.space = args.Results.space;
    end

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

    opt.dummy_scans = args.Results.dummy_scans;

    opt.anatOnly = args.Results.anat_only;

    % stats
    opt.dir.preproc = args.Results.preproc_dir;
    opt.model.file = args.Results.model_file;
    opt.glm.roibased.do = args.Results.roi_based;

  end

end

%% high level actions

function preprocess(opt)

  if isempty(opt.taskName) || numel(opt.taskName) > 1
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

  cpp_spm('action', 'uninit');

end

function stats(opt)

  if opt.glm.roibased.do
    bidsFFX('specify', opt);
    bidsRoiBasedGLM(opt);
  else
    bidsFFX('specifyAndEstimate', opt);
    bidsFFX('contrasts', opt);
    bidsResults(opt);
  end

  cpp_spm('action', 'uninit');

end

%% low level actions

function initCppSpm(dev)
  %
  % Adds the relevant folders to the path for a given session.
  % Has to be run to be able to use CPP_SPM.
  %
  % USAGE::
  %
  %   initCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 1
    dev = false;
  end

  opt.verbosity = 2;
  opt.msg.color = '';

  octaveVersion = '4.0.3';
  matlabVersion = '8.6.0';

  % octave packages
  installlist = {'io', 'statistics', 'image'};

  thisDirectory = fileparts(mfilename('fullpath'));

  global CPP_SPM_INITIALIZED
  global CPP_SPM_PATHS

  if isempty(CPP_SPM_INITIALIZED)

    pathSep = ':';
    if ~isunix
      pathSep = ';';
    end

    CPP_SPM_PATHS = fullfile(thisDirectory);
    CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, ...
                        pathSep, ...
                        genpath(fullfile(thisDirectory, 'src')));

    % for some reasons this folder was otherwise not added to the path in Octave
    CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, ...
                        pathSep, ...
                        genpath(fullfile(thisDirectory, 'src', 'workflows', 'stats')));

    libList = {'spmup', ...
               'spm_2_bids'};

    for i = 1:numel(libList)
      CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, ...
                          genpath(fullfile(thisDirectory, 'lib', libList{i})));
    end

    libList = {'mancoreg', ...
               'bids-matlab', ...
               'slice_display', ...
               'panel-2.14', ...
               'utils'};
    for i = 1:numel(libList)
      CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, pathSep, ...
                          fullfile(thisDirectory, 'lib', libList{i}));
    end

    CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, pathSep, ...
                        fullfile(thisDirectory, 'lib', 'brain_colours', 'code'));

    CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, pathSep, ...
                        fullfile(thisDirectory, 'lib', 'riksneurotools', 'GLM'));

    if dev
      CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, pathSep, ...
                          fullfile(thisDirectory, 'tests', 'utils'));
    end

    addpath(CPP_SPM_PATHS, '-begin');

    checkDependencies(opt);
    printCredits(opt);

    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'initCppRoi'));

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

    CPP_SPM_INITIALIZED = true();

    detectCppSpm();

  else
    printToScreen('\n\nCPP_SPM already initialized\n\n');

  end

end

function uninitCppSpm()
  %
  % Removes the added folders fromthe path for a given session.
  %
  % USAGE::
  %
  %   uninitCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDirectory = fileparts(mfilename('fullpath'));

  global CPP_SPM_INITIALIZED
  global CPP_SPM_PATHS

  if isempty(CPP_SPM_INITIALIZED) || ~CPP_SPM_INITIALIZED
    fprintf('\n\nCPP_SPM not initialized\n\n');
    return

  else
    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'uninitCppRoi'));
    rmpath(CPP_SPM_PATHS);
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
  % (C) Copyright 2019 CPP_SPM developers

  % Elapsed time is 284 seconds.

  tic;

  cpp_spm('action', 'dev');

  cd(fileparts(mfilename('fullpath')));

  if isGithubCi
    printToScreen('\nThis is github CI\n');
  else
    printToScreen('\nThis is not github CI\n');
  end

  printToScreen(sprintf('\nHome is %s\n', getenv('HOME')));

  warning('OFF');

  spm('defaults', 'fMRI');

  folderToCover = fullfile(pwd, 'src');
  testFolder = fullfile(pwd, 'tests');

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

%% contsants

function value = bids_apps_actions()

  value = {'preprocess', 'stats'};

end

function value = low_level_actions()
  value = {'init'; ...
           'uninit'; ...
           'dev'
           'version'; ...
           'run_tests'};

end

function value = allowed_actions()

  value = cat(1, bids_apps_actions(), low_level_actions());

end

%% helpers functions

function detectCppSpm()

  workflowsDir = cellstr(which('bidsSpatialPrepro.m', '-ALL'));

  if isempty(workflowsDir)
    error('CPP_SPM is not in your MATLAB / Octave path.\n');

  elseif numel(workflowsDir) > 1
    printToScreen('CPP_SPM seems to appear in several different folders:\n');
    for i = 1:numel(workflowsDir)
      fprintf('  * %s\n', fullfile(workflowsDir{i}, '..', '..'));
    end
    error('Remove all but one with ''pathtool''' .\ n'); % or ''spm_rmpath

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

function cpp_spm(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   cpp_spm('init')
  %   cpp_spm('uninit')
  %   cpp_spm('dev')
  %
  % :param action:
  % :type action: string
  %
  % :returns: - :action: (type) (dimension)
  %
  % Example::
  %
  % (C) Copyright 2022 CPP_SPM developers

  % TODO
  %     input_datasets
  %     output_location
  %     analysis_level
  %     participant_label
  %     action
  %     bids_filter_file
  %     dry_run
  %     option

  p = inputParser;

  addRequired(p, 'action', @ischar);

  parse(p, varargin{:});

  action = p.Results.action;

  switch lower(action)

    case 'init'

      initCppSpm();

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

  end

end

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

  opt.verbosity = 1;

  octaveVersion = '4.0.3';
  matlabVersion = '8.6.0';

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

    libList = { ...
               'spmup', ...
               'spm_2_bids'};

    for i = 1:numel(libList)
      CPP_SPM_PATHS = cat(2, CPP_SPM_PATHS, ...
                          genpath(fullfile(thisDirectory, 'lib', libList{i})));
    end

    libList = { ...
               'mancoreg', ...
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
          disp(['loading ' packageName]);
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
    fprintf(1, '\n\nCPP_SPM already initialized\n\n');

  end

end

function detectCppSpm()

  workflowsDir = cellstr(which('bidsSpatialPrepro.m', '-ALL'));

  if isempty(workflowsDir)
    error('CPP_SPM is not in your MATLAB / Octave path.\n');

  elseif numel(workflowsDir) > 1
    fprintf('CPP_SPM seems to appear in several different folders:\n');
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

  cpp_spm('init');

  cd(fileparts(mfilename('fullpath')));

  if isGithubCi
    fprintf(1, '\nThis is github CI\n');
  else
    fprintf(1, '\nThis is not github CI\n');
  end

  fprintf('\nHome is %s\n', getenv('HOME'));

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
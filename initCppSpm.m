function initCppSpm()
  %
  % Adds the relevant folders to the path for a given session.
  % Has to be run to be able to use CPP_SPM.
  %
  % USAGE::
  %
  %   initCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.verbosity = 1;

  octaveVersion = '4.0.3';
  matlabVersion = '8.6.0';

  installlist = {'io', 'statistics', 'image'};

  global CPP_SPM_INITIALIZED

  if isempty(CPP_SPM_INITIALIZED)

    thisDirectory = fileparts(mfilename('fullpath'));

    addpath(genpath(fullfile(thisDirectory, 'src')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'spmup')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'spm_2_bids')));

    libList = { ...
               'mancoreg', ...
               'NiftiTools', ...
               'bids-matlab', ...
               'slice_display', ...
               'panel-2.14', ...
               'utils'};

    for i = 1:numel(libList)
      addpath(fullfile(thisDirectory, 'lib', libList{i}));
    end

    addpath(fullfile(thisDirectory, 'lib', 'brain_colours', 'code'));
    addpath(fullfile(thisDirectory, 'lib', 'riksneurotools', 'GLM'));

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

  else
    printToScreen('\n\nCPP_SPM already initialized\n\n', opt);

  end

  %   %-Detect SPM directory
  % %--------------------------------------------------------------------------
  % SPMdir = cellstr(which('spm.m','-ALL'));
  % if isempty(SPMdir)
  %     fprintf('SPM is not in your %s path.\n',software);
  %     return;
  % elseif numel(SPMdir) > 1
  %     fprintf('SPM seems to appear in several different folders:\n');
  %     for i=1:numel(SPMdir)
  %         fprintf('  * %s\n',SPMdir{i});
  %     end
  %     fprintf('Remove all but one with ''pathtool'' or ''spm_rmpath''.\n');
  %     return;
  % else
  %     fprintf('SPM is installed in: %s\n',fileparts(SPMdir{1}));
  % end
  % SPMdir = fileparts(SPMdir{1});

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

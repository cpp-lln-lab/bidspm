function initCppSpm()
  %
  % adds the relevant folders to the path
  %
  % (C) Copyright 2021 CPP_SPM developers

  global CPP_SPM_INITIALIZED

  if isempty(CPP_SPM_INITIALIZED)

    % directory with this script becomes the current directory
    thisDirectory = fileparts(mfilename('fullpath'));

    % we add all the subfunctions that are in the sub directories
    addpath(genpath(fullfile(thisDirectory, 'src')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'mancoreg')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'NiftiTools')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'spmup')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'utils')));

    addpath(fullfile(thisDirectory, 'lib', 'bids-matlab'));
    addpath(fullfile(thisDirectory, 'lib', 'slice_display'));
    addpath(fullfile(thisDirectory, 'lib', 'panel-2.14'));
    addpath(fullfile(thisDirectory, 'lib', 'brain_colours', 'code'));

    checkDependencies();

    printCredits();

    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'initCppRoi'));

    CPP_SPM_INITIALIZED = true();

  else
    fprintf('\n\nCPP_SPM already initialized\n\n');

  end

end

function initCppSpm()
  %
  % adds the relevant folders to the path
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.verbosity = 1;

  global CPP_SPM_INITIALIZED

  if isempty(CPP_SPM_INITIALIZED)

    thisDirectory = fileparts(mfilename('fullpath'));

    addpath(genpath(fullfile(thisDirectory, 'src')));
    addpath(genpath(fullfile(thisDirectory, 'lib', 'spmup')));

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

    checkDependencies(opt);
    printCredits(opt);

    run(fullfile(thisDirectory, 'lib', 'CPP_ROI', 'initCppRoi'));

    CPP_SPM_INITIALIZED = true();

  else
    printToScreen('\n\nCPP_SPM already initialized\n\n', opt);

  end

end

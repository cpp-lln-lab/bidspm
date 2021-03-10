% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function initCppSpm()

  % directory with this script becomes the current directory
  WD = fileparts(mfilename('fullpath'));

  % we add all the subfunctions that are in the sub directories
  addpath(genpath(fullfile(WD, 'src')));
  addpath(genpath(fullfile(WD, 'lib', 'mancoreg')));
  addpath(genpath(fullfile(WD, 'lib', 'NiftiTools')));
  addpath(genpath(fullfile(WD, 'lib', 'spmup')));
  addpath(genpath(fullfile(WD, 'lib', 'utils')));

  addpath(fullfile(WD, 'lib', 'bids-matlab'));

end

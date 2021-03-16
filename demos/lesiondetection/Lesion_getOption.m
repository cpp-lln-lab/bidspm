% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function opt = Lesion_getOption()
  %
  % Returns a structure that contains the options chosen by the user to run the source processing
  % batch workflow
  %
  % USAGE::
  %
  %  opt = Lesion_getOption()
  %
  % :returns: - :optSource: (struct)

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'rest';

  % define group options
  opt.groups = {'control', 'blind'};

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'output', '...');
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')));

  % specify the result to compute

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end

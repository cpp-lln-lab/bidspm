% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function opt = setOptions(task, subLabel)

  if strcmp(task, 'MoAE')

    opt.dataDir = fullfile( ...
                           fileparts(mfilename('fullpath')), ...
                           '..', '..', 'demos',  'MoAE', 'output', 'MoAEpilot');

    opt.taskName = 'auditory';

  else

    opt.taskName = task;
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), '..', 'dummyData');

  end

  if nargin > 1
    opt.subjects = {subLabel};
  end

end

function value = bidsAppsActions()
  % Returns a cell array of the supported bids apps actions

  % (C) Copyright 2022 bidspm developers

  input_file = fullfile(fileparts(mfilename('fullpath')), ...
                        '..', ...
                        'bidspm', ...
                        'data', ...
                        'allowed_actions.json');

  value = bids.util.jsondecode(input_file);

end

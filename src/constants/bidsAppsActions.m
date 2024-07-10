function value = bidsAppsActions()
  % Returns a cell array of the supported bids apps actions

  % (C) Copyright 2022 bidspm developers

  try
    input_file = fullfile(fileparts(mfilename('fullpath')), ...
                          '..', ...
                          'bidspm', ...
                          'data', ...
                          'allowed_actions.json');

    value = bids.util.jsondecode(input_file);
  catch
    value = {'copy'; ...
             'create_roi'; ...
             'preprocess'; ...
             'smooth'; ...
             'default_model'; ...
             'stats'; ...
             'contrasts'; ...
             'results'; ...
             'specify_only'; ...
             'bms'; ...
             'bms-posterior'; ...
             'bms-bms'};
  end

end

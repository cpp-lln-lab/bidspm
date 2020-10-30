% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function saveOptions(opt)

  filename = fullfile(pwd, ['options', ...
                            '_task-', opt.taskName, ...
                            '_date-' datestr(now, 'yyyymmddHHMM'), ...
                            '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  fprintf('Options saved in: \n\n');

end

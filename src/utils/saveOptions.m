% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function saveOptions(opt)

  filename = fullfile(pwd, ['options', ...
                            '_task-', opt.taskName, ...
                            '_date-' datestr(now, 'yyyymmddHHMM'), ...
                            '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  fprintf('Options saved in: \n\n');

end

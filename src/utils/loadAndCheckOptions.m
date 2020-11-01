% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = loadAndCheckOptions(opt)
  % opt = loadAndCheckOptions(opt)
  %
  % if not argument is provived checks in the current directory for
  % ``opt_task-*.json`` files and loads the most recent one by name
  % (using the date- key).
  %
  % then checks the content of the opt structure and adds missing information

  if nargin < 1 || isempty(opt)
    opt = spm_select('FPList', pwd, '^options_task-.*.json$');
  end

  if isstruct(opt)
    opt = checkOptions(opt);
    fprintf(1, '\nOptions are locked & loaded.\n\n');
    return
  end

  % finds most recent option file
  if size(opt, 1) > 1
    containsDate = cellfun(@any, strfind(cellstr(opt), '_date-'));
    opt = opt(containsDate, :);
    opt = sortrows(opt);
    opt = opt(end, :);
  end

  if ischar(opt) && exist(opt, 'file')
    fprintf(1, '\nReading option from: %s.\n', opt);
    opt = spm_jsonread(opt);
  else
    error('the requested file does not exist: %s', opt);
  end

  opt = checkOptions(opt);
  fprintf(1, '\nOptions are locked & loaded.\n\n');

end

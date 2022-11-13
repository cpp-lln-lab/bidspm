function bugReport(opt, ME)
  %
  % Write a small bug report.
  %
  % USAGE::
  %
  %   bugReport(opt)
  %
  %

  % (C) Copyright 2022 bidspm developers

  opt.verbosity = 3;
  if nargin < 1
    opt.dryRun = false;
  end

  [OS, GeneratedBy] = getEnvInfo(opt);

  json.GeneratedBy = GeneratedBy;
  json.OS = OS;
  if nargin > 1
    json.ME = ME;
  end

  logFile = spm_file(sprintf('error_%s.log', timeStamp()), 'cpath');
  bids.util.jsonwrite(logFile, json);
  printToScreen(sprintf(['\nERROR LOG SAVED:\n\t%s\n', ...
                         'Use it when opening an issue <a href="%s">%s</a>.\n'], ...
                        logFile, ...
                        [returnRepoURL() '/issues/new/choose'], ...
                        [returnRepoURL() '/issues/new/choose']), ...
                opt, ...
                'format', 'red');

end

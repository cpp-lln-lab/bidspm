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

  if nargin < 1
    opt.verbosity = 2;
    opt.dryRun = false;
  end

  [OS, GeneratedBy] = getEnvInfo(opt);

  json.GeneratedBy = GeneratedBy;
  json.OS = OS;
  if nargin > 1
    json.ME = ME;
  end

  logFile = sprintf('error_%s.log', timeStamp());
  bids.util.jsonwrite(logFile, json);

end

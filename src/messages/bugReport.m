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

  output_dir = pwd;
  if isfield(opt, 'dir') && isfield(opt.dir, 'output')
    output_dir = opt.dir.output;
  end
  output_dir = fullfile(output_dir, 'error_logs');
  spm_mkdir(output_dir);

  if nargin > 1
    json.ME = ME;

    for i = 1:numel(json.ME.stack)
      stackTrace{i} = sprintf('Error in %s\n\t\tline %i in %s', ...
                              json.ME.stack(i).name, ...
                              json.ME.stack(i).line, ...
                              json.ME.stack(i).file); %#ok<*AGROW>
    end

    logger('INFO', sprintf('%s\n Error %s occurred:%s%s', ...
                           json.ME.message, ...
                           json.ME.identifier, ...
                           bids.internal.create_unordered_list(stackTrace)), ...
           'color', 'red');
  end
  logFile = spm_file(fullfile(output_dir, sprintf('error_%s.log', timeStamp())), 'cpath');
  bids.util.jsonwrite(logFile, json);
  printToScreen(sprintf(['ERROR LOG SAVED:\n\t%s\n', ...
                         'Use it when opening an issue:\n\t%s.\n\n'], ...
                        bids.internal.format_path(logFile), ...
                        [returnRepoURL() '/issues/new/choose']), ...
                opt, ...
                'format', 'red');

end

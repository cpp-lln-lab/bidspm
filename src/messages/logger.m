function logMsg = logger(varargin)
  %
  %   Returns logger message
  %
  % USAGE::
  %
  %   logger(logLevel, msg, opt, filename)
  %

  % (C) Copyright 2022 bidspm developers

  default_opt = struct('verbosity', 2);

  args = inputParser;

  addRequired(args, 'logLevel', @ischar);
  addRequired(args, 'msg', @ischar);
  addOptional(args, 'opt', default_opt, @isstruct);
  addOptional(args, 'filename', '', @ischar);
  addOptional(args, 'id', '', @ischar);

  parse(args, varargin{:});

  logLevel = args.Results.logLevel;
  msg = args.Results.msg;
  opt = args.Results.opt;
  filename = args.Results.filename;
  id = args.Results.id;

  [~, filename, ext] = fileparts(filename);

  baseMsg = sprintf('\n[%s] bidspm - %s\t\t\t%s\n%s\n', ...
                    datestr(now, 'HH:MM:SS'), ...
                    logLevel, ...
                    [filename, ext]);

  logMsg = sprintf('\n[%s] bidspm - %s\t\t\t%s\n%s\n', ...
                   datestr(now, 'HH:MM:SS'), ...
                   logLevel, ...
                   [filename, ext], ...
                   msg);

  if ismember(logLevel, {'ERROR'})
    tmpOpt = opt;
    tmpOpt.verbosity = 3;
    printToScreen(logMsg, tmpOpt, 'format', 'red');
    errorHandling(filename, id, msg, false);
  end

  switch opt.verbosity

    case 1
      if ismember(logLevel, {'WARNING'})
        printToScreen(baseMsg, opt, 'format', [1, 0.5, 0]);
        tmpOpt = opt;
        tmpOpt.verbosity = 3;
        errorHandling(filename, id, msg, true, true);
      end

    case 2
      if ismember(logLevel, {'WARNING'})
        printToScreen(baseMsg, opt, 'format', [1, 0.5, 0]);
        errorHandling(filename, id, msg, true, true);
      end
      if ismember(logLevel, {'INFO'})
        printToScreen(logMsg, opt, 'format', 'blue');
      end

    case 3
      if ismember(logLevel, {'WARNING'})
        printToScreen(baseMsg, opt, 'format', [1, 0.5, 0]);
        errorHandling(filename, id, msg, true, true);
      end
      if ismember(logLevel, {'INFO', 'DEBUG'})
        printToScreen(logMsg, opt, 'format', 'blue');
      end
  end

end

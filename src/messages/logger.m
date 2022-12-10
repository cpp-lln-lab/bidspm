function logMsg = logger(varargin)
  %
  %   Returns logger message
  %
  % USAGE::
  %
  %   logger(logLevel, msg, 'options', opt, 'filename', filename, 'id', id)
  %
  % :param logLevel:
  % :type  logLevel: char
  %
  % :param msg:
  % :type  msg: char
  %

  % (C) Copyright 2022 bidspm developers

  silenceOctaveWarning();

  ALLOWED_LOG_LEVELS = {'ERROR', 'WARNING', 'INFO', 'DEBUG'};

  default_opt = struct('verbosity', 2);

  args = inputParser;

  addRequired(args, 'logLevel', @ischar);
  addRequired(args, 'msg', @ischar);
  addParameter(args, 'options', default_opt, @isstruct);
  addParameter(args, 'filename', '', @ischar);
  addParameter(args, 'id', '', @ischar);

  parse(args, varargin{:});

  logLevel = args.Results.logLevel;
  msg = args.Results.msg;
  opt = args.Results.options;
  filename = args.Results.filename;
  id = args.Results.id;

  [~, filename, ext] = fileparts(filename);

  if ~ismember(logLevel, ALLOWED_LOG_LEVELS)
    logger('ERROR', ...
           ['log levels must be one of:' createUnorderedList(ALLOWED_LOG_LEVELS)], ...
           'filename', mfilename(), ...
           'id', 'wrongLogLevel');
  end

  format = '\n[%s] bidspm - %s\t\t\t\t%s\n%s\n';

  logMsg = sprintf(format, ...
                   datestr(now, 'HH:MM:SS'), ...
                   logLevel, ...
                   [filename, ext], ...
                   msg);

  if ismember(logLevel, {'ERROR'})
    tmpOpt = opt;
    tmpOpt.verbosity = 3;
    errorHandling(filename, id, logMsg, false);
  end

  switch opt.verbosity

    case 1
      if ismember(logLevel, {'WARNING'})
        errorHandling(filename, id, logMsg, true, true);
      end

    case 2
      if ismember(logLevel, {'WARNING'})
        errorHandling(filename, id, logMsg, true, true);
      end
      if ismember(logLevel, {'INFO'})
        printToScreen(logMsg, opt, 'format', 'blue');
      end

    case 3
      if ismember(logLevel, {'WARNING'})
        errorHandling(filename, id, logMsg, true, true);
      end
      if ismember(logLevel, {'INFO', 'DEBUG'})
        printToScreen(logMsg, opt, 'format', 'blue');
      end
  end

end

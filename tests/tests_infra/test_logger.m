function test_suite = test_logger %#ok<*STOUT>
  %

  % (C) Copyright 2020 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_logger_basic()

  levels = {'ERROR', 'WARNING', 'INFO', 'DEBUG'};

  for verbosity = 0:3
    for iLevel = 1:numel(levels)

      logLevel = levels{iLevel};
      opt.verbosity = verbosity;
      msg = sprintf('log level: %s - verbosity: %i', logLevel, opt.verbosity);

      logger(logLevel, msg, opt, mfilename);

    end
  end
end

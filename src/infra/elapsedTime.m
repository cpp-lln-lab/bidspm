function [startTime, runTime] = elapsedTime(opt, action, startTime, runTime, nbIteration)
  %
  % USAGE::
  %
  %   [start, runTime] = elapsedTime(input, startTime, runTime, nbIteration)
  %
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 4
    runTime = [];
  end

  switch action

    case 'start'

      startTime = tic;

    case 'stop'

      printDone(opt);

      t = toc(startTime(end));
      msg = sprintf(' elapsed time: %s', formatDuration(t));
      printToScreen(msg, opt);

      runTime(end + 1) = t;
      ETA = mean(runTime) * (nbIteration - numel(runTime));
      msg = sprintf('\n ETA: %s', formatDuration(ETA));
      printToScreen(msg, opt);

      printHorizontalLine(opt, 27);

    case 'globalStart'

      startTime = tic;

    case 'globalStop'

      printToScreen('\n\n********* Pipeline done :) *********\n', opt);

      t = toc(opt.globalStart);
      msg = sprintf('  global elapsed time: %s', formatDuration(t));
      printToScreen(msg, opt);

      printHorizontalLine(opt, 36);

  end

end

function printDone(opt)
  printToScreen('\n\n********* Done :) *********\n', opt);
end

function printHorizontalLine(opt, length)
  printToScreen(['\n' repmat('*', 1, length) '\n\n'], opt);
end

function string = formatDuration(duration)
  string = datestr(datenum(0, 0, 0, 0, 0, duration), 'HH:MM:SS');
end

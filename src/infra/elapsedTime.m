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

      msg = '********* Done :) *********\n';
      msg = [msg, ' elapsed time: %s\n'];
      msg = [msg, ' ETA: %s'];
      msg = [msg, returnHorizontalLine(27)];

      t = toc(startTime(end));
      runTime(end + 1) = t;
      ETA = mean(runTime) * (nbIteration - numel(runTime));

      msg = sprintf(msg, formatDuration(t), formatDuration(ETA));

      logger('INFO', msg, opt, mfilename);

    case 'globalStart'

      startTime = tic;

    case 'globalStop'

      msg = '********* Pipeline done :) *********\n';
      msg = [msg, '  global elapsed time: %s'];
      msg = [msg, returnHorizontalLine(36)];

      t = toc(opt.globalStart);
      msg = sprintf(msg, formatDuration(t));

      logger('INFO', msg, opt, mfilename);

  end

end

function line = returnHorizontalLine(length)
  line = ['\n' repmat('*', 1, length)];
end

function string = formatDuration(duration)
  string = datestr(datenum(0, 0, 0, 0, 0, duration), 'HH:MM:SS');
end

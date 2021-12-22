function [startTime, runTime] = elapsedTime(input, startTime, runTime, nbIteration)
    %
    % USAGE::
    %
    %   [start, runTime] = elapsedTime(input, startTime, runTime, nbIteration)
    %
    %
    % (C) Copyright 2021 CPP_SPM developers

    if nargin < 3
        runTime = [];
    end

    switch input

        case 'start'

            startTime = tic;

        case 'stop'

            fprintf('\n\n********* Done :) *********\n\n');

            fprintf(' elapsed time is: ')
            t=toc(startTime(end));
            disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));

            runTime(end+1) = t;
            ETA = mean(runTime) * (nbIteration - numel(runTime));
            fprintf('\n ETA: ')
            disp(datestr(datenum(0,0,0,0,0,ETA),'HH:MM:SS'));

            fprintf('\n***************************\n\n');

        case 'globalStart'

            startTime = tic;

        case 'globalStop'

            fprintf('\n\n********* Pipeline done :) *********\n\n');
            fprintf('  global elapsed time is: ')
            t=toc(startTime);
            disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
            fprintf('\n************************************\n\n');

    end

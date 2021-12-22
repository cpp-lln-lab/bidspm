function start = elapsedTime(input, varargin)

global GLOBAL_START
    
switch input

    case 'start'

        start = tic;

    case 'stop'

        fprintf('\n\n\n********* Done :) *********\n\n');
        fprintf(' elapsed time is: ')
        t=toc;
        disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
        fprintf('\n***************************\n\n');

    case 'globalStart'

        GLOBAL_START = tic;

    case 'globalStop'
        
        fprintf('\n\n\n********* Pipeline done :) *********\n\n');
        fprintf('  global elapsed time is: ')
        t=toc(GLOBAL_START);
        disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
        fprintf('\n************************************\n\n');

end

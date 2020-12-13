function globalStart = elapsedTime(input, varargin)

switch input

    case 'start'

        tic;

    case 'stop'

        fprintf('\n\n\n********* Done :) *********\n\n');
        fprintf(' elapsed time is: ')
        t=toc;
        disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
        fprintf('\n***************************\n\n');

    case 'globalStart'

        globalStart = tic;

    case 'globalStop'

        globalStart = varargin{1};
        
        fprintf('\n\n\n********* Pipeline done :) *********\n\n');
        fprintf('  global elapsed time is: ')
        t=toc(globalStart);
        disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
        fprintf('\n************************************\n\n');

end

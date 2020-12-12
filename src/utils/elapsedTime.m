function elapsedTime(input)

switch input
    
    case 'start' 
        
        tic
    
    
    case 'stop' 
        
        fprintf('\n\n\n******** Done :) ********\n\n');
        fprintf('elapsed time is: ')
        t=toc;
        disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));
        fprintf('\n*************************\n\n');
        
end
    

    
   
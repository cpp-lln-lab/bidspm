%List of all possible contrasts 
% Should match the FFX contrasts in NAME and ORDER

a = {   
    'V_U';
    'V_D';
    'A_D';
    'V_D - A_D'
    };


Session = struct('con',[]);
for ii = 1:size(a,1)
Session(ii).con = a{ii};
end

save ConOfInterest.mat Session
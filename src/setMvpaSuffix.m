% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function mvpaSuffix = setMvpaSuffix(isMVPA)
    mvpaSuffix = '';
    if isMVPA
        mvpaSuffix = '_MVPA';
    end
end

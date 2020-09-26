% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function saveMatlabBatch(matlabbatch, batchType, opt, subID)
    % saveMatlabBatch(batch, batchType, opt, subID)
    %
    % Also save some basic environnment info
    %
    % batch : matlabbatch
    % batchType: (string) name to give to the batch file
    %
    %

    if nargin < 4 || isempty(subID)
        subID = 'group';
    else
        subID = ['sub-' subID];
    end

    jobsDir = fullfile(opt.jobsDir, subID);
    [~, ~, ~] = mkdir(jobsDir);

    filename = sprintf( ...
                       '%s_jobs_matlabbatch_SPM12_%s.mat', ...
                       datestr(now, 'yyyymmdd_HHMM'), ...
                       batchType);

    [OS, GeneratedBy] = getEnvInfo();
    GeneratedBy(1).Description = batchType;

    save(fullfile(jobsDir, filename), 'matlabbatch');

    % write as json for more "human readibility"
    opts.indent = '    ';

    json.matlabbach = matlabbatch;
    json.GeneratedBy = GeneratedBy;
    json.OS = OS;

    try 
    spm_jsonwrite( ...
                  fullfile(jobsDir, strrep(filename, '.mat', '.json')), ...
                  json, opts);
    catch
        % if we have a dependendy object in the batch then we can't save the
        % batch structure as a json
        json = rmfield(json, 'matlabbach');
        spm_jsonwrite( ...
            fullfile(jobsDir, strrep(filename, '.mat', '.json')), ...
            json, opts);
    end

end

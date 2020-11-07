% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function saveMatlabBatch(matlabbatch, batchType, opt, subID)
  %
  % Also save some basic environnment info.
  %
  % USAGE::
  %
  %   saveMatlabBatch(matlabbatch, batchType, opt, [subID])
  %
  % :param matlabbatch: 
  % :type matlabbatch: structure
  % :param batchType: 
  % :type batchType: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subID: 
  % :type subID: string
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

  save(fullfile(jobsDir, filename), 'matlabbatch', '-v7');

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

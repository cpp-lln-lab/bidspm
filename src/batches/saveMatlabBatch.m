function saveMatlabBatch(matlabbatch, batchType, opt, subLabel)
  %
  % Also save some basic environnment info.
  %
  % USAGE::
  %
  %   saveMatlabBatch(matlabbatch, batchType, opt, [subLabel])
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param batchType:
  % :type batchType: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 4 || isempty(subLabel)
    subLabel = 'group';
  else
    subLabel = ['sub-' subLabel];
  end

  jobsDir = fullfile(opt.dir.jobs, subLabel);
  [~, ~, ~] = mkdir(jobsDir);

  filename = sprintf( ...
                     '%s_jobs_matlabbatch_SPM12_%s.mat', ...
                     datestr(now, 'yyyymmdd_HHMM'), ...
                     batchType);

  [OS, GeneratedBy] = getEnvInfo(opt);
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
    % if we have a dependency object in the batch 
    % then we can't save the batch structure as a json
    % so we remove the batch
    json = rmfield(json, 'matlabbach');
    spm_jsonwrite( ...
                  fullfile(jobsDir, strrep(filename, '.mat', '.json')), ...
                  json, opts);
  end

end

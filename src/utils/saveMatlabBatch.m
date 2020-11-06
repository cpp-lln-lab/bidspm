% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function saveMatlabBatch(matlabbatch, batchType, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % 
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

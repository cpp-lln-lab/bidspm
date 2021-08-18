function saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel)
  %
  % Saves the SPM matlabbatch and runs it
  %
  % USAGE::
  %
  %   saveAndRunWorkflow(matlabbatch, batchName, opt, [subLabel])
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param batchName: name of the batch
  % :type batchName: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  % :param subLabel: subject label
  % :type subLabel: string
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 4
    subLabel = [];
  end

  if ~isempty(matlabbatch)

    saveMatlabBatch(matlabbatch, batchName, opt, subLabel);

    if ~opt.dryRun
      spm_jobman('run', matlabbatch);
    end

  else
    errorHandling(mfilename(), ...
                  'emptyBatch', ...
                  'This batch is empty & will not be run.', ...
                  true, ...
                  opt.verbosity);

  end

  manageWorkersPool('close', opt);

end

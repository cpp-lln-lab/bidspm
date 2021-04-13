function saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel)
  %
  % Saves the SPM matlabbatch and runs it
  %
  % USAGE::
  %
  %   saveAndRunWorkflow(matlabbatch, batchName, opt, [subID])
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param batchName: name of the batch
  % :type batchName: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  % :param subID: subject ID
  % :type subID: string
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 4
    subLabel = [];
  end

  if ~isempty(matlabbatch)

    saveMatlabBatch(matlabbatch, batchName, opt, subLabel);

    spm_jobman('run', matlabbatch);

  else
    warning('This batch is empty and will not be run.');

  end

  manageWorkersPool('close', opt);

end

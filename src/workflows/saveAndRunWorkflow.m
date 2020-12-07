% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function saveAndRunWorkflow(matlabbatch, batchName, opt, subID)
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

  if nargin < 4
    subID = [];
  end

  if ~isempty(matlabbatch)

    saveMatlabBatch(matlabbatch, batchName, opt, subID);

    spm_jobman('run', matlabbatch);

  else
    warning('This batch is empty and will not be run.');

  end

end

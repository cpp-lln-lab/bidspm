function status = saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel)
  %
  % Saves the SPM matlabbatch and runs it
  %
  % USAGE::
  %
  %   saveAndRunWorkflow(matlabbatch, batchName, opt, [subLabel])
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :param batchName: name of the batch
  % :type batchName: char
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  % :type opt: structure
  %
  % :param subLabel: subject label
  % :type subLabel: char
  %

  % (C) Copyright 2019 bidspm developers

  if nargin < 4
    subLabel = [];
  end

  status = true;

  if ~isempty(matlabbatch)

    saveMatlabBatch(matlabbatch, batchName, opt, subLabel);

    if ~opt.dryRun
      spm_jobman('run', matlabbatch);
    else
      status = false;
    end

  else
    status = false;

    id = 'emptyBatch';
    msg  = 'This batch is empty & will not be run.';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());

  end

end

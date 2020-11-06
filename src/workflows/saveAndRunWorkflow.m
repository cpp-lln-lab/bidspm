% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function saveAndRunWorkflow(matlabbatch, batchName, opt, subID)
  %
  % Saves the SPM matlabbatch and runs it
  %
  % USAGE::
  %
  %   saveAndRunWorkflow(matlabbatch, batchName, opt, [subID])
  %

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

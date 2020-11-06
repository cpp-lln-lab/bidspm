function saveAndRunWorkflow(matlabbatch, batchName, opt, subID)
  
  if nargin < 4 
    subID = [];
  end
  
  if ~isempty(matlabbatch)
    
    saveMatlabBatch(matlabbatch, batchName, opt, subID);

    spm_jobman('run', matlabbatch);
    
  else
    warning('This batch is empty and will not be run.')
    
  end
  
end
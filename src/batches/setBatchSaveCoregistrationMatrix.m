% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, subID, opt)

  % create name of the output file based on the name of the first image of the
  % first session
  sessions = getInfo(BIDS, subID, opt, 'Sessions');
  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subID, sessions{1}, runs{1}, opt);

  fileName = strrep(fileName, '_bold.nii', '_from-scanner_to-T1w_mode-image_xfm.mat');

  matlabbatch{end + 1}.cfg_basicio.var_ops.cfg_save_vars.name = fileName;
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.outdir = {subFuncDataDir};
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'transformationMatrix';

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = ...
      cfg_dep( ...
              'Coregister: Estimate: Coregistration Matrix', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.coregister}, ...
                        '.', 'val', '{}', {opt.orderBatches.coregister}, ...
                        '.', 'val', '{}', {opt.orderBatches.coregister}, ...
                        '.', 'val', '{}', {opt.orderBatches.coregister}), ...
              substruct('.', 'M'));

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;

end

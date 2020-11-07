% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, subID, opt)
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
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param argin3: (dimension) optional argument
  % Options chosen for the analysis. See ``checkOptions()``.
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  
  printBatchName('saving coregistration matrix');

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

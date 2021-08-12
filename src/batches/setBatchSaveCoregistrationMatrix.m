function matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subID)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt:
  % :type opt: Options chosen for the analysis. See ``checkOptions()``.
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('saving coregistration matrix', opt);

  % create name of the output file based on the name
  % of the first image of the first session
  if (isfield(opt.metadata, 'SliceTiming') && ...
      ~isempty(opt.metadata.SliceTiming)) || ...
          ~isempty(opt.sliceOrder)
    opt.query.desc = 'stc';
  end
  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{1}, runs{1}, opt);
  p = bids.internal.parse_filename(fileName);
  p.use_schema = false;
  p.suffix = 'xfm';
  p.ext = '.mat';
  p.entities.desc = '';
  p.entities.space = '';
  p.entities.run = '';
  p.entities.from = 'scanner';
  p.entities.to = opt.anatReference.type;
  p.entities.mode = 'image';

  fileName = bids.create_filename(p);

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

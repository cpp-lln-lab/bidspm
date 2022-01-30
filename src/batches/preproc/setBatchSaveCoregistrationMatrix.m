function matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel)
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

  if opt.anatOnly
    return
  end

  printBatchName('saving coregistration matrix', opt);

  % create name of the output file based on the name
  % of the first image of the first session
  opt.query.desc = '';
  opt = addStcToQuery(BIDS, opt, subLabel);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{1}, runs{1}, opt);
  p = bids.internal.parse_filename(fileName);

  p.suffix = 'xfm';
  p.ext = '.mat';
  p.entities.desc = '';
  p.entities.space = '';
  p.entities.run = '';
  p.entities.from = 'scanner';
  p.entities.to = opt.bidsFilterFile.t1w.suffix;
  p.entities.mode = 'image';

  bidsFile = bids.File(p);

  matlabbatch{end + 1}.cfg_basicio.var_ops.cfg_save_vars.name = bidsFile.filename;
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.outdir = {subFuncDataDir};
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'transformationMatrix';

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = ...
      cfg_dep( ...
              'Coregister: Estimate: Coregistration Matrix', ...
              returnDependency(opt, 'coregister'), ...
              substruct('.', 'M'));

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;

end

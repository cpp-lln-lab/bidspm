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
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  %
  % :param opt:
  % :type opt: Options chosen for the analysis. See ``checkOptions()``.
  %
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
  bf = bids.File(fileName);

  bf.suffix = 'xfm';
  bf.extension = '.mat';
  bf.entities.desc = '';
  bf.entities.space = '';
  bf.entities.run = '';
  % TODO make more general
  % this assumes we are doing a func to T1 coregistration
  bf.entities.from = 'scanner';
  bf.entities.to = opt.bidsFilterFile.t1w.suffix;
  bf.entities.mode = 'image';

  matlabbatch{end + 1}.cfg_basicio.var_ops.cfg_save_vars.name = bf.filename;
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.outdir = {subFuncDataDir};
  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'transformationMatrix';

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = ...
      cfg_dep( ...
              'Coregister: Estimate: Coregistration Matrix', ...
              returnDependency(opt, 'coregister'), ...
              substruct('.', 'M'));

  matlabbatch{end}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;

end

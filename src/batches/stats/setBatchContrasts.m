function matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess)
  %
  % Add a contrast to the batch for SPM.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess)
  %
  % :param matlabbatch:
  % :type  matlabbatch: cell
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param spmMatFile:
  % :type  spmMatFile: char
  %
  % :param consess:
  % :type  consess: cell
  %
  % :return: matlabbatch
  % :rtype: structure

  % (C) Copyright 2019 bidspm developers

  if isempty(consess)
    return
  end

  printBatchName('contrasts specification', opt);

  matlabbatch{end + 1}.spm.stats.con.spmmat = {spmMatFile};
  matlabbatch{end}.spm.stats.con.consess = consess;
  matlabbatch{end}.spm.stats.con.delete = 1;

end

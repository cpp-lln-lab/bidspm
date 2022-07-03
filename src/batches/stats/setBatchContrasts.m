function matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess)
  %
  % Short description of what the function does goes here.
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
  %             See  also: checkOptions
  %
  % :param spmMatFile:
  % :type  spmMatFile: char
  %
  % :param consess:
  % :type  consess: cell
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  if isempty(consess)
    return
  end

  printBatchName('contrasts specification', opt);

  matlabbatch{end + 1}.spm.stats.con.spmmat = {spmMatFile};
  matlabbatch{end}.spm.stats.con.consess = consess;
  matlabbatch{end}.spm.stats.con.delete = 1;

end

% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchContrasts(matlabbatch, spmMatFile, consess)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchContrasts(matlabbatch, spmMatFile, consess)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param spmMatFile:
  % :type spmMatFile: string
  % :param consess:
  % :type consess: cell
  %
  % :returns: - :matlabbatch: (structure)
  %

  printBatchName('contrasts specification');

  matlabbatch{end + 1}.spm.stats.con.spmmat = spmMatFile;
  matlabbatch{end}.spm.stats.con.consess = consess;
  matlabbatch{end}.spm.stats.con.delete = 1;

end

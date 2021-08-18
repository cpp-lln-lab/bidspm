function matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subLabel)

  %
  % template to creae new setBatch functions
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type matlabbatch:
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('name for this batch');

  matlabbatch{end + 1}.spm.something = BIDS;
  matlabbatch{end}.spm.else = opt;
  matlabbatch{end}.spm.other = subLabel;

end

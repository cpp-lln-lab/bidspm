% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subID, info, varargin)
  %
  % template to creae new setBatch functions
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subID, info, varargin)
  %
  % :param matlabbatch:
  % :type matlabbatch:
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job

  printBatchName('name for this batch');

  matlabbatch{end + 1}.spm.something = BIDS;
  matlabbatch{end}.spm.else = opt;
  matlabbatch{end}.spm.other = subID;
  matlabbatch{end}.spm.thing = info;

end

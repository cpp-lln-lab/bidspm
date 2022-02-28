function [grpLvlCon, iNode] = getGrpLevelContrast(opt)
  %
  % Returns the contrast part of the dataset step of the BIDS model
  %
  % USAGE::
  %
  %   function [grpLvlCon, iStep] = getGrpLevelContrast(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: - :grpLvlCon:
  %           - :iStep:
  %
  % (C) Copyright 2019 CPP_SPM developers

  bm = bids.Model('file', opt.model.file);
  [grpLvlCon, iNode] = bm.get_dummy_contrasts('Level', 'dataset');

end

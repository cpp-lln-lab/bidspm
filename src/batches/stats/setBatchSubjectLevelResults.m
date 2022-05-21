function matlabbatch = setBatchSubjectLevelResults(varargin)
  %
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subLabel, result)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure)
  %
  % See also: bidsResults, setBatchResults
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, opt, subLabel, result] = deal(varargin{:});

  result.nbSubj = 1;

  load(fullfile(result.dir, 'SPM.mat'), 'SPM');

  result.contrastNb = getContrastNb(result, opt, SPM);
  if isempty(result.contrastNb)
    msg = sprintf('Skipping contrast named %s', char(result.name));
    errorHandling(mfilename(), 'skippingContrastResults', msg, true, true);
    return
  end

  % replace name that has likely been regexified by now
  result.name = SPM.xCon(result.contrastNb).name;

  result.label = subLabel;

  result.outputName = defaultOuputNameStruct(opt, result);

  matlabbatch = setBatchResults(matlabbatch, result);

end

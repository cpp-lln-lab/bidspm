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

    result.name = char(result.name);
    result.name = regexify(result.name);

    msg = sprintf('Skipping contrast named "%s"', result.name(2:end - 1));
    errorHandling(mfilename(), 'skippingContrastResults', msg, true, opt.verbosity);
    return

  end

  if numel(result.contrastNb) > 1

    printAvailableContrasts(SPM, opt);

    msg = sprintf('\nGetting too many contrasts in SPM file\n%s\nfor the name:\n %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.name);
    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, opt.verbosity);
    return

  end

  % replace name that has likely been regexified by now
  result.name = SPM.xCon(result.contrastNb).name;

  result.label = subLabel;

  result.outputName = defaultOuputNameStruct(opt, result);

  matlabbatch = setBatchResults(matlabbatch, result);

end

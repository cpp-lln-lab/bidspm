function contrastNb = getContrastNb(result, opt, SPM)
  %
  % identify the contrast nb actually has the name the user asked
  %
  % USAGE::
  %
  %     contrastNb = getContrastNb(result, opt, SPM)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  contrastNb = [];

  if ~isfield(result, 'name') || ...
      isempty(result.name) || ...
      (iscell(result.name) && all(cellfun('isempty', result.name))) || ...
      strcmp(result.name, '^$')

    printAvailableContrasts(SPM, opt);

    msg = 'No contrast name specified';

    errorHandling(mfilename(), 'missingContrastName', msg, true, true);

    return

  end

  result.name = regexify(result.name);

  contrastNb = regexp({SPM.xCon.name}', result.name, 'match');

  contrastNb = find(~cellfun('isempty', contrastNb));

  if isempty(contrastNb)

    printAvailableContrasts(SPM, opt);

    msg = sprintf('\nThis SPM file\n%s\n does not contain a contrast named:\n "%s"', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.name(2:end - 1));

    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, true);

    return

  end

end

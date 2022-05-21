function contrastNb = getContrastNb(result, opt, SPM)
  %
  % identify which contrast nb actually has the name the user asked
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

    msg = sprintf('\nThis SPM file\n%s\n does not contain a contrast named:\n %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.name);

    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, true);

    return

  end

  if numel(contrastNb) > 1

    printAvailableContrasts(SPM, opt);

    msg = sprintf('\nGetting too many contrasts in SPM file\n%s\nfor the name:\n %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.name);

    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, true);

  end

end

function printAvailableContrasts(SPM, opt)
  printToScreen('List of contrast in this SPM file\n', opt);
  printToScreen(strjoin({SPM.xCon.name}, '\n'), opt);
  printToScreen('\n', opt);
end

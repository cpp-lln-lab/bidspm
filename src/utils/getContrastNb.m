function contrastNb = getContrastNb(result, opt, SPM)
  %
  % identify which contrast nb actually has the name the user asked
  %
  %
  % (C) Copyright 2019 CPP_SPM developers


  if ~isfield(result, 'name') || isempty(result.name) || strcmp(result.name, '^$')

    printAvailableContrasts(SPM, opt);

    msg = 'No contrast name specified';

    errorHandling(mfilename(), 'missingContrastName', msg, true, true);

  end
  
  contrastNb = regexp({SPM.xCon.name}', result.name, 'match');
  
  contrastNb = find(~cellfun('isempty', contrastNb));

  if isempty(contrastNb)

    printAvailableContrasts(SPM, opt);

    msg = sprintf('\nThis SPM file %s does not contain a contrast named %s', ...
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

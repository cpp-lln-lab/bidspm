function [idx, allowedSpaces] = isMni(input)
  %
  %
  %

  % (C) Copyright 2022 bidspm developers

  if ischar(input)
    input = cellstr(input);
  end

  allowedSpaces = {'IXI549Space', ...
                   'MNI', ...
                   'MNIColin27', ...
                   'MNI152NLin2009aSym', ...
                   'MNI152NLin2009aASym', ...
                   'MNI152NLin2009bSym', ...
                   'MNI152NLin2009bASym', ...
                   'MNI152NLin2009cSym', ...
                   'MNI152NLin2009cASym', ...
                   'MNI152Lin', ...
                   'MNI152NLin6Sym', ...
                   'MNI152NLin6ASym', ...
                   'MNI305', ...
                   'ICBM452AirSpace', ...
                   'ICBM452Warp5Space'};

  % need to lowercase everyone in this horrible way because
  %
  % idx = ismember(lower(input), lower(space));
  %
  % fails in CI with
  %
  % failure: Error using lower
  % Cell elements must be character arrays.
  %
  allowedSpaces = cellstr(lower(char(allowedSpaces)));

  if iscellstr(input)
    input = cellstr(lower(char(input)));
  elseif ischar(input)
    input = {lower(input)};
  end

  idx = ismember(input, allowedSpaces);

end

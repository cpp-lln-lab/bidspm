function idx = isMni(input)
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if ischar(input)
    input = cellstr(input);
  end

  space = {'IXI549Space'
           'MNI'
           'MNIColin27'
           'MNI152NLin2009aSym'
           'MNI152NLin2009aASym'
           'MNI152NLin2009bSym'
           'MNI152NLin2009bASym'
           'MNI152NLin2009cSym'
           'MNI152NLin2009cASym'
           'MNI152Lin'
           'MNI152NLin6Sym'
           'MNI152NLin6ASym'
           'MNI305'
           'ICBM452AirSpace'
           'ICBM452Warp5Space'
          };

  idx = ismember(lower(input), lower(space));

end

function silenceOctaveWarning()
  %
  % USAGE::
  %
  %   silenceOctaveWarning()
  %

  % (C) Copyright 2020 Remi Gau

  if isOctave
    warning('off', 'setGraphicWindow:noGraphicWindow');
    warning('off', 'Octave:mixed-string-concat');
  end

end

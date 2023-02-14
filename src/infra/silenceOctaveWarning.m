function silenceOctaveWarning()
  %
  % USAGE::
  %
  %   silenceOctaveWarning()
  %

  % (C) Copyright 2020 Remi Gau

  if bids.internal.is_octave()
    warning('off', 'setGraphicWindow:noGraphicWindow');
    warning('off', 'Octave:mixed-string-concat');
    warning('off', 'Octave:shadowed-function');
  end

end

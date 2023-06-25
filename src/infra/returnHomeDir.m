function home = returnHomeDir()
  %
  % Return the fullpath of the home directory of the user.
  %
  % USAGE::
  %
  %  home = returnHomeDir()
  %

  % (C) Copyright 2023 bidspm developers

  if ispc
    home = getenv('USERPROFILE');
  else
    home = getenv('HOME');
  end

end

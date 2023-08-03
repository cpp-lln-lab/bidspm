function pth = tempName()
  %
  % Creates a temporary directory and returns its fullpath
  %

  % (C) Copyright 2023 bidspm developers

  pth = tempname();
  mkdir(pth);

end

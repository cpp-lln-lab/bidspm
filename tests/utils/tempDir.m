function value = tempDir()
  %

  % (C) Copyright 2023 bidspm developers
  value = tempname();
  mkdir(value);
end

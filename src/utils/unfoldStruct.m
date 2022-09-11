function unfoldStruct(input)
  %
  % USAGE::
  %
  %   unfoldStruct(input)
  %
  % (C) Copyright 2022 bidspm developers

  name = inputname(1);
  show = true;
  unfold(input, name, show);
  fprintf(1, '\n');

end

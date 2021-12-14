function string = regexify(string)
  %
  % Turns a string into a simple regex.
  %
  %   ``foo``  --> ``^foo$``
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~strcmp(string(1), '^')
    string = ['^' string];
  end
  if ~strcmp(string(end), '$')
    string = [string '$'];
  end
end

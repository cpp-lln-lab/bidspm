function string = deregexify(string)
  %
  % Removes eventual initial ^ and ending $
  %
  %   Input   -->    Output
  %
  %   ``^foo$`` --> ``foo``
  %
  % USAGE::
  %
  %   string = deregexify(string)
  %
  %

  % (C) Copyright 2022 bidspm developers

  if isempty(string)
    return
  end
  if strcmp(string(1), '^')
    string = string(2:end);
  end
  if strcmp(string(end), '$')
    string = string(1:end - 1);
  end
end

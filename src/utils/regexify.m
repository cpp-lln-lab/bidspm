function string = regexify(string)
  %
  % Turns a string into a simple regex. Useful to query bids dataset with
  % bids.query that by default expects will treat its inputs as regex.
  %
  %   Input   -->    Output
  %
  %   ``foo`` --> ``^foo$``
  %
  % USAGE::
  %
  %   string = regexify(string)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~strcmp(string(1), '^')
    string = ['^' string];
  end
  if ~strcmp(string(end), '$')
    string = [string '$'];
  end
end

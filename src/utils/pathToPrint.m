function pth = pathToPrint(pth)
  %
  % Replaces single '\' by '/' on Windows
  % to prevent escaping warning when printing a path
  %
  % :param pth: If pth is a cellstr of paths, pathToPrint will work
  %             recursively on it.
  % :type pth: char or cellstr
  %

  % (C) Copyright 2021 bidspm developers

  if isunix()
    return
  end

  if ischar(pth) && size(pth, 1) > 1
    pth = cellstr(pth);
  end

  if ischar(pth)
    pth = strrep(pth, '\', '/');

  elseif iscell(pth)
    for i = 1:numel(pth)
      pth{i} = pathToPrint(pth{i});
    end
  end

end

function f = initMontageFigure(shape, visibility)
  % (C) Copyright 2024 bidspm developers

  scr_size = get(0, 'ScreenSize');
  dist = scr_size(4);
  if scr_size(3) < dist
    dist = scr_size(3);
  end
  % Create figure - outerposition = [left bottom width height]

  if strcmp(shape, 'max')
    f = figure('visible', visibility, ...
               'units', 'normalized', ...
               'outerposition', [0 0 1 1]);
  elseif strcmp(shape, 'square')
    f = figure('visible', visibility, ...
               'units', 'pixels', ...
               'outerposition', [0 0 dist dist]);
  else
    f = figure('visible', visibility, ...
               'units', 'pixels', ...
               'outerposition', [0 0 dist dist]);
  end
end

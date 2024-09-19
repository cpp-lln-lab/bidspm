function montage = fmrwhy_util_createMontage(img, columns, rotate, str, clrmp, visibility, shape, cxs)

  % (C) Copyright 2022 bidspm developers

  % Simple function to create a montage / mosaic of multiple slices from a single 3D
  % image matrix. TODO: Needs improvement i.t.o RAS/LAS orientation specification
  % and image layout...
  %
  % INPUT:
  % img           - 3D (x,y,z) image matrix
  % columns       - number of columns in montage (rows are calculated accordingly)
  % rotate        - rotate images 90 deg clockwise? yes = 1; no = 0.
  % str           - figure title
  % clrmp         - figure colormap
  % visibility    - show figure?
  %
  % OUTPUT:
  % output        - structure with montage data

  montage = struct;
  [Ni, Nj, Nk] = size(img);

  % Rotate image slices if required
  if rotate
    img_orig = img;
    clear img;
    for p = 1:Nk
      img(:, :, p) = rot90(img_orig(:, :, p));
    end
  end

  % Determine amount of rows and filler slices
  rows = floor(Nk / columns);
  if rows == 0
    rows = 1;
  end
  fill = mod(Nk, columns);
  if fill == 0
    N_fill = 0;
  else
    N_fill = columns - mod(Nk, columns);
  end
  if rotate
    filler = zeros(Nj, Ni);
  else
    filler = zeros(Ni, Nj);
  end

  montage.rows = rows;
  montage.columns = columns;
  montage.N_fill = N_fill;

  parts = {};
  % 1 - Concatenate slices together horizontally, per row (except last).
  % 2 - Concatenate rows together vertically
  for i = 1:rows
    for j = 1:columns
      if j == 1
        parts{i} = img(:, :, columns * (i - 1) + j);
      else
        parts{i} = cat(2, parts{i}, img(:, :, columns * (i - 1) + j));
      end
    end
    if i == 1
      whole = parts{i};
    else
      whole = cat(1, whole, parts{i});
    end
  end

  % 1 - Concatenate filler slices to last row, if required.
  % 2 - Concatenate last row to whole matrix, if required.
  if N_fill ~= 0
    % last row
    last_parts = img(:, :, rows * columns + 1);
    for k = (rows * columns + 2):Nk
      last_parts = cat(2, last_parts, img(:, :, k));
    end
    for m = 1:N_fill
      last_parts = cat(2, last_parts, filler);
    end
    montage.whole_img = cat(1, whole, last_parts);
  else
    montage.whole_img = whole;
  end

  % Get screen size for plotting - [1 1 w h]
  scr_size = get(0, 'ScreenSize');
  dist = scr_size(4);
  if scr_size(3) < dist
    dist = scr_size(3);
  end

  % Create figure - outerposition = [left bottom width height]
  if strcmp(shape, 'max')
    f = figure('visible', visibility, 'units', 'normalized', 'outerposition', [0 0 1 1]);
  elseif strcmp(shape, 'square')
    f = figure('visible', visibility, 'units', 'pixels', 'outerposition', [0 0 dist dist]);
  else
    f = figure('visible', visibility, 'units', 'pixels', 'outerposition', [0 0 dist dist]);
    % daspect manual;
  end
  ax = subplot(1, 1, 1);
  im = imagesc(ax, montage.whole_img);
  colormap(clrmp); % colorbar;
  if nargin == 8
    if ~isempty(cxs)
      caxis(ax, cxs);
    end
  end
  % title(str);
  montage.im = im;
  montage.f = f;
  montage.ax = ax;

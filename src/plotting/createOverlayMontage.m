function output = createOverlayMontage(varargin)

  % (C) Copyright 2024 bidspm developers

  % fmrwhy_util_createOverlayMontage(tsnr_img{i}, overlayImg, 9, 1, '', ...
  % 'hot', 'off', 'max', [0 250], [33, 168, 10], tsnr_saveAss{i});

  % Function to create montages of images/rois overlaid on a template image

  rgbcolors = [255, 255, 191; ...
               215, 25, 28; ...
               253, 174, 97; ...
               171, 217, 233; ...
               44, 123, 182];

  args = inputParser;

  addRequired(args, 'templateImg');
  addRequired(args, 'overlayImg');
  addParameter(args, 'columns', 9, @isnumeric);
  addParameter(args, 'rotate', true, @islogical);
  addParameter(args, 'cmap', 'gray', @ischar);
  addParameter(args, 'visibility', 'on', @ischar);
  addParameter(args, 'shape', 'max', @ischar); % max or square
  addParameter(args, 'cxs', 'auto');
  addParameter(args, 'rgbcolors', rgbcolors);
  addParameter(args, 'saveAs', '');

  parse(args, varargin{:});

  templateImg = args.Results.templateImg;
  overlayImg = args.Results.overlayImg;
  columns = args.Results.columns;
  rotate = args.Results.rotate;
  cmap = args.Results.cmap;
  visibility = args.Results.visibility;
  shape = args.Results.shape;
  cxs = args.Results.cxs;
  rgbcolors = args.Results.rgbcolors;
  saveAs = args.Results.saveAs;

  % Structure to save output
  output = struct;
  alpha = 0.2;
  plot_contour = 1;
  rgbcolors = rgbcolors / 255;

  % Create background montage
  montage_template = createMontage(templateImg, ...
                                   'columns', columns, ...
                                   'rotate', rotate, ...
                                   'cmap', cmap, ...
                                   'visibility', 'off', ...
                                   'shape', shape, ...
                                   'cxs', cxs);

  % Create figures with background montage and overlaid masks
  f = initMontageFigure(shape, visibility);
  imagesc(montage_template.whole_img);
  colormap(cmap);
  if ~isempty(cxs)
    caxis(cxs);
  end
  ax = gca;
  outerpos = ax.OuterPosition;
  ti = ax.TightInset;
  left = outerpos(1) + ti(1);
  bottom = outerpos(2) + ti(2);
  ax_width = outerpos(3) - ti(1) - ti(3);
  ax_height = outerpos(4) - ti(2) - ti(4);
  ax.Position = [left bottom ax_width ax_height];
  hold(ax, 'on');
  [Nimx, Nimy] = size(montage_template.whole_img);
  oo = ones(Nimx, Nimy);

  if iscell(overlayImg)
    for i = 1:numel(overlayImg)
      montage_overlay{i} = createMontage(overlayImg{i}, ...
                                         'columns', columns, ...
                                         'rotate', rotate, ...
                                         'cmap', cmap, ...
                                         'visibility', 'off', ...
                                         'shape', shape, ...
                                         'cxs', 'auto');
    end
  else
    montage_overlay = {};
    montage_overlay{1} = createMontage(overlayImg, ...
                                       'columns', columns, ...
                                       'rotate', rotate, ...
                                       'cmap', cmap, ...
                                       'visibility', 'off', ...
                                       'shape', shape, ...
                                       'cxs', 'auto');
  end

  for i = 1:numel(montage_overlay)
    rbgclr = rgbcolors(i, :);
    clr = cat(3, rbgclr(1) * oo, rbgclr(2) * oo, rbgclr(3) * oo);
    imC = imagesc(ax, clr);
    set(imC, 'AlphaData', alpha * montage_overlay{i}.whole_img);
    if plot_contour
      bound_whole_bin = bwboundaries(montage_overlay{i}.whole_img);
      Nblobs_bin = numel(bound_whole_bin);
      for b = 1:Nblobs_bin
        p = plot(ax, bound_whole_bin{b, 1}(:, 2), bound_whole_bin{b, 1}(:, 1), ...
                 'color', rbgclr, 'LineWidth', 1);
      end
    end
  end

  hold(ax, 'off');
  set(ax, 'xtick', []);
  set(ax, 'xticklabel', []);
  set(ax, 'ytick', []);
  set(ax, 'yticklabel', []);
  set(ax, 'ztick', []);
  set(ax, 'zticklabel', []);

  output.ax = ax;
  output.f = f;

  if saveAs ~= 0
    print(f, saveAs, '-dpng', '-r0');
  end
  % Close necessary figure handles
  close(montage_template.f);
  for i = 1:numel(montage_overlay)
    close(montage_overlay{i}.f);
  end
  if strcmp(visibility, 'off')
    close(f);
  end

function davg = getDist2surf(varargin)
  %
  % Loads the pial surface and computes the mean distance to the surface.
  %
  %
  % USAGE::
  %
  %   davg = getDist2surf(anatImage, opt)
  %
  % :param anatImage:
  % :type anatImage: cell
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :returns: - :davg: (float) (1 x 1)
  %
  % Example::
  %

  % (C) Copyright 2022 bidspm developers

  isFile = @(x) exist(x, 'file') == 2;

  args = inputParser;
  addRequired(args, 'anatImage', isFile);
  addRequired(args, 'opt', @isstruct);
  parse(args, varargin{:});

  anatImage = args.Results.anatImage;
  opt = args.Results.opt;

  davg = 50;

  path = spm_fileparts(anatImage);

  bf = bids.File(anatImage);

  surface_file = spm_select('FPList', ...
                            path, ...
                            ['^.*sub-' bf.entities.sub '.*_desc-.*' bf.suffix '.*\.gii$']);

  if size(surface_file, 1) == 1

    FV = gifti(surface_file);
    center = FV.vertices(FV.faces(:, :), :);
    center = reshape(center, [size(FV.faces, 1) 3 3]);
    center = squeeze(mean(center, 2));
    ori_dist = sqrt(sum((center .* -1).^2, 2))';
    davg = mean(ori_dist); %#ok<UDIM>

  else

    printToScreen(' Could not compute the average distance to the brain surface.\n', opt);
    printToScreen(' Using the default value instead.\n', opt);

  end

end

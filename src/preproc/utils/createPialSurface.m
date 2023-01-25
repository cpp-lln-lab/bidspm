function surfaceFile = createPialSurface(varargin)
  %
  % creates a gifti image of the the pial surface
  %
  % EXAMPLE::
  %
  %   surfaceFile = createPialSurface(grayMatterFile, whiteMatterFile, opt)
  %
  %
  % :param grayMatterFile: gray matter probabilistic segmentation
  % :type  grayMatterFile: valid file path
  %
  % :param whiteMatterFile: white matter probabilistic segmentation
  % :type  whiteMatterFile: valid file path
  %
  % :param opt:
  % :type  opt: structure
  %

  % (C) Copyright 2023 bidspm developers

  isFile = @(x) exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'grayMatterFile', isFile);
  addRequired(args, 'whiteMatterFile', isFile);
  addOptional(args, 'opt', struct('verbosity', 2), @isstruct);

  parse(args, varargin{:});

  gmFile = args.Results.grayMatterFile;
  wmFile = args.Results.whiteMatterFile;
  opt = args.Results.opt;

  files = char({gmFile, wmFile});

  logger('DEBUG', sprintf('creating pial surface with:%s', ...
                          createUnorderedList({gmFile, wmFile})), ...
         'options', opt, ...
         'filename', mfilename);

  spm_check_orientations(spm_vol(files));

  out = spm_surf(files, 2);
  surfaceFile = out.surffile{1};

end

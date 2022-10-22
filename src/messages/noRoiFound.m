function status = noRoiFound(varargin)
  %
  % USAGE::
  %
  %   status = noRoiFound(opt, roiList, folder)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  % :param roiList: obligatory argument.
  % :type roiList: cell
  % :param folder: optional argument. default: ``''``
  % :type folder: path
  %
  % :returns: - :status: (boolean)
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  defaultFolder = '';

  isDir = @(x) isdir(x);

  addRequired(args, 'opt', @isstruct);
  addOptional(args, 'roiList', @isstruct);
  addParameter(args, 'folder', defaultFolder, isDir);

  parse(args, varargin{:});

  status = false;

  if isempty(args.Results.roiList) || isempty(args.Results.roiList{1})

    status = true;

    tolerant = true;
    msg = sprintf('No ROI found in folder: %s', args.Results.folder);
    id = 'noRoiFile';
    errorHandling(mfilename(), id, msg, tolerant, args.Results.opt.verbosity);

  end

end

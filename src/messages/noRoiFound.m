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

  isFolder = @(x) isdir(x);

  addRequired(args, 'opt', @isstruct);
  addOptional(args, 'roiList', @isstruct);
  addParameter(args, 'folder', defaultFolder, isFolder);

  parse(args, varargin{:});

  status = false;

  if isempty(args.Results.roiList) || isempty(args.Results.roiList{1})

    status = true;

    msg = sprintf('No ROI found in folder: %s', args.Results.folder);
    id = 'noRoiFile';
    logger('WARNING', msg, 'id', id, 'filename', mfilename, 'options', args.Results.opt);

  end

end

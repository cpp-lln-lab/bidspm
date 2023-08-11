function spmSessOut = orderAndPadCounfoundMatFile(varargin)
  %
  % When doing model comparison all runs must have same number of confound regressors
  % and have exactly the same names (be from the same conditions), so
  %
  %  - so we pad them with zeros if necessary
  %  - we reorder them
  %
  % USAGE::
  %
  %   status = padCounfoundMatFile(spmSess, opt)
  %
  % :param spmSess: obligatory argument.
  % :type spmSess: cell
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type opt: structure
  %
  % :returns: - :status: (boolean)
  %
  %
  % See also: reorderCounfounds
  %

  % (C) Copyright 2022 bidspm developers

  isSpmSessStruct = @(x) isstruct(x) && isfield(x, 'counfoundMatFile');

  args = inputParser;
  addRequired(args, 'spmSess', isSpmSessStruct);
  addRequired(args, 'opt', @isstruct);
  parse(args, varargin{:});

  spmSess = args.Results.spmSess;
  opt = args.Results.opt;

  spmSessOut = spmSess;

  if ~opt.glm.useDummyRegressor
    return
  end

  allConfoundsNames = {};

  matFiles  = {spmSess.counfoundMatFile}';

  % no point in reordering things across runs if there is only one
  if numel(matFiles) == 1
    return
  end

  for iRun = 1:numel(matFiles)
    fileToLoad = matFiles{iRun};
    if isempty(fileToLoad)
      continue
    end
    load(matFiles{iRun}, 'names');
    allConfoundsNames = cat(1, allConfoundsNames, names); %#ok<NODEF>
  end

  for iRun = 1:numel(matFiles)

    fileToLoad = matFiles{iRun};
    if isempty(fileToLoad)
      continue
    end
    load(fileToLoad, 'names', 'R');

    [names, R] = reorderCounfounds(names, R, allConfoundsNames);

    bf = bids.File(fileToLoad);
    bf.entities.desc = 'confoundsPadded';
    bf.suffix = 'regressors';
    outputFilename = fullfile(fileparts(fileToLoad), bf.filename);

    save(outputFilename, 'names', 'R');
    spmSessOut(iRun).counfoundMatFile = outputFilename;

  end

end

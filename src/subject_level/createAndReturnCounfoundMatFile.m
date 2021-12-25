function counfoundMatFile = createAndReturnCounfoundMatFile(opt, subLabel, tsvFile)
  %
  % Creates an ``_regressors.mat`` in the subject level GLM folder.
  %
  % For a given ``_regressors.tsv`` file and ``_model.json``,
  % it creates a  ``_regressors.mat`` file that can directly be used
  % for the GLM specification of a subject level model.
  %
  % The file is moved directly into the folder of the GLM.
  %
  % USAGE::
  %
  %   counfoundMatFile = createAndReturnCounfoundMatFile(opt, subLabel, tsvFile)
  %
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  % :param tsvFile: fullpath name of the tsv file.
  % :type tsvFile: string
  %
  % :returns: :counfoundMatFile: (string) fullpath name of the file created.
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  X = getBidsDesignMatrix(opt.model.file, 'run');

  if iscell(tsvFile)
    tsvFile = tsvFile{1};
  end

  content = bids.util.tsvread(tsvFile);

  if isempty(content)
    msg = sprintf('This confound file is empty:\n %s\n', tsvFile);
    errorHandling(mfilename(), 'emptyConfoundFle', msg, true, opt.verbosity);
    counfoundMatFile = '';
    return
  end

  % filter based on model content
  names = fieldnames(content);
  names = intersect(X, names);

  R = [];
  
  for col = 1:numel(names)
    if opt.glm.maxNbVols ~= Inf && numel(content.(names{col})) > opt.glm.maxNbVols
        R(:, col) = content.(names{col})(1:opt.glm.maxNbVols);
    else
        R(:, col) = content.(names{col});
    end
  end

  % save the confounds as a matfile
  p = bids.internal.parse_filename(tsvFile);
  p.ext = '.mat';

  bidsFile = bids.File(p);

  ffxDir = getFFXdir(subLabel, opt);
  counfoundMatFile = fullfile(ffxDir, bidsFile.filename);

  save(counfoundMatFile, ...
       'names', 'R', ...
       '-v7');

end

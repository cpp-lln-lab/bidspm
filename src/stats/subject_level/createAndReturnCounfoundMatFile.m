function counfoundMatFile = createAndReturnCounfoundMatFile(opt, tsvFile)
  %
  % Creates a ``_regressors.mat`` in the subject level GLM folder.
  %
  % For a given ``_regressors.tsv`` file and ``_model.json``,
  % it creates a  ``_regressors.mat`` file that can directly be used
  % for the GLM specification of a subject level model.
  %
  % The file is moved directly into the folder of the GLM.
  %
  % USAGE::
  %
  %   counfoundMatFile = createAndReturnCounfoundMatFile(opt, tsvFile)
  %
  % :param opt:     Options chosen for the analysis.
  %                 See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt:      structure
  %
  % :param tsvFile: fullpath name of the tsv file.
  % :type  tsvFile: char
  %
  % :returns: :counfoundMatFile: (string) fullpath name of the file created.
  %
  % See also: setBatchSubjectLevelGLMSpec, createConfounds
  %

  % (C) Copyright 2019 bidspm developers

  % TODO handle when there are more than one confound file
  if iscell(tsvFile)
    tsvFile = tsvFile{1};
  end

  content = bids.util.tsvread(tsvFile);

  if isempty(content)
    msg = sprintf('This confound file is empty:\n %s\n', tsvFile);
    id = 'emptyConfoundFle';
    logger('WARNING', msg, 'id', id, 'filename', mfilename, 'options', opt);
    counfoundMatFile = '';
    return
  end

  designMatrix = opt.model.bm.getBidsDesignMatrix();

  [names, R] = createConfounds(content, designMatrix, opt.glm.maxNbVols); %#ok<*ASGLU>

  % save the confounds as a matfile
  bf = bids.File(tsvFile);
  bf.extension = '.mat';

  % reset task query to original value
  % in case we are merging several tasks in one GLM
  opt.query.task = opt.taskName;

  ffxDir = getFFXdir(bf.entities.sub, opt);
  counfoundMatFile = fullfile(ffxDir, bf.filename);

  save(counfoundMatFile, ...
       'names', 'R', ...
       '-v7');

end

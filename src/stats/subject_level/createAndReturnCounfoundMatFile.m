function [counfoundFile, counfoundMeta] = createAndReturnCounfoundMatFile(opt, tsvFile)
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
  %                 See :func:`checkOptions`.
  % :type opt:      structure
  %
  % :param tsvFile: fullpath name of the tsv file.
  % :type  tsvFile: char
  %
  % :return: counfoundMatFile: (string) fullpath name of the file created.
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
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    counfoundFile = '';
    counfoundMeta = '';
    return
  end

  bm = opt.model.bm;

  designMatrix = bm.getBidsDesignMatrix();

  transformers = bm.getBidsTransformers();
  content = bids.transformers(transformers, content);

  [names, R] = createConfounds(content, designMatrix, opt.glm.maxNbVols); %#ok<*ASGLU>
  [names, R] = sanitizeConfounds(names, R);

  % save the confounds as a matfile
  bf = bids.File(tsvFile);
  bf.extension = '.mat';

  % reset task query to original value
  % in case we are merging several tasks in one GLM
  opt.query.task = opt.taskName;

  ffxDir = getFFXdir(bf.entities.sub, opt);
  if exist(ffxDir, 'dir') == 0
    spm_mkdir(ffxDir);
  end
  counfoundFile = fullfile(ffxDir, bf.filename);

  if isempty(names) || isempty(R)
    counfoundFile = '';
    counfoundMeta = '';
    return
  end
  save(counfoundFile, ...
       'names', 'R', ...
       '-v7');

  scrubbed = returnNumberScrubbedTimePoints(R);
  content = struct('NumberTimePoints', size(R, 1), ...
                   'ProportionCensored', scrubbed / size(R, 1));

  if content.ProportionCensored > 0.5
    bf = bids.File(counfoundFile);
    msg = sprintf('%0.0f of time points censored for run:%', ...
                  content.ProportionCensored, ...
                  bids.internal.create_unordered_list(bf.entities));
    logger('WARNING', msg, ...
           'options', opt, ...
           'filename', mfilename(), ...
           'id', 'LargeNumberTimePointsCensored');
  end

  counfoundMeta = spm_file(counfoundFile, 'ext', '.json');
  bids.util.jsonencode(counfoundMeta, content);

end

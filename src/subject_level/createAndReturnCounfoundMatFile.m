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

  if iscell(tsvFile)
    tsvFile = tsvFile{1};
  end

  content = bids.util.tsvread(tsvFile);

  % TODO filter based on model content
  names = fieldnames(content);

  R = [];
  for col = 1:numel(names)
    R(:, col) = content.(names{col});
  end

  % save the confounds as a matfile
  p = bids.internal.parse_filename(tsvFile);
  p.ext = '.mat';
  p.use_schema = false;

  ffxDir = getFFXdir(subLabel, opt);
  counfoundMatFile = fullfile(ffxDir, bids.create_filename(p));

  save(counfoundMatFile, ...
       'names', 'R', ...
       '-v7');

end

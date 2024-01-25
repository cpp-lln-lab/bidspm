function onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile, runDuration)
  %
  % For a given ``_events.tsv`` file and ``_model.json``,
  % it creates a  ``_onset.mat`` file that can directly be used
  % for the GLM specification of a subject level model.
  %
  % The file is moved directly into the folder of the GLM.
  %
  % USAGE::
  %
  %   onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile)
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :param tsvFile: fullpath name of the tsv file.
  % :type  tsvFile: char
  %
  % :param runDuration: Total duration of the run (in seconds). Optional.
  %                     Events occurring later than this will be excluded.
  % :type  runDuration: numeric
  %
  % :returns: :onsetFilename: (path) fullpath name of the file created.
  %
  % See also: convertOnsetTsvToMat
  %
  %

  % (C) Copyright 2019 bidspm developers

  if iscell(tsvFile)
    tsvFile = tsvFile{1};
  end

  msg = sprintf('\n  Reading the tsv file : %s \n', bids.internal.format_path(tsvFile));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  ffxDir = getFFXdir(subLabel, opt);
  onsetFilename = convertOnsetTsvToMat(opt, tsvFile, runDuration, ffxDir);

end

function onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile)
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
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :param tsvFile: fullpath name of the tsv file.
  % :type  tsvFile: char
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

  msg = sprintf('\n  Reading the tsv file : %s \n', pathToPrint(tsvFile));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  onsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % move file into the FFX directory
  [~, filename, ext] = spm_fileparts(onsetFilename);

  % reset task query to original value
  % in case we are merging several tasks in one GLM
  opt.query.task = opt.taskName;

  ffxDir = getFFXdir(subLabel, opt);
  movefile(onsetFilename, ffxDir);

  onsetFilename = fullfile(ffxDir, [filename ext]);

end

function onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile)
  %
  % Creates an ``_onset.mat`` in the subject level GLM folder.
  %
  % For a given ``_events.tsv`` file and ``_model.json``,
  % it creates a  ``_onset.mat`` file that can directly be used
  % for the GLM specification of a subject level model.
  %
  % The file is moved directly into the folder of the GLM.
  %
  % USAGE::
  %
  %   onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile, funcFWHM)
  %
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  % :param tsvFile: fullpath name of the tsv file.
  % :type tsvFile: string
  %
  % :returns: :onsetFilename: (string) fullpath name of the file created.
  %
  % See also: convertOnsetTsvToMat
  %
  % (C) Copyright 2019 CPP_SPM developers

  if iscell(tsvFile)
    tsvFile = tsvFile{1};
  end

  onsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % move file into the FFX directory
  [~, filename, ext] = spm_fileparts(onsetFilename);
  ffxDir = getFFXdir(subLabel, opt);
  movefile(onsetFilename, ffxDir);

  onsetFilename = fullfile(ffxDir, [filename ext]);

end

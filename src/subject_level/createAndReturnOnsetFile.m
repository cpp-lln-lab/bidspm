function onsetFileName = createAndReturnOnsetFile(opt, subID, tsvFile, funcFWHM)
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
  %   onsetFileName = createAndReturnOnsetFile(opt, subID, tsvFile, funcFWHM)
  %
  % :param opt:
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param tsvFile: fullpath name of the tsv file.
  % :type tsvFile: string
  % :param funcFWHM: size of the FWHM gaussian kernel used to the subject level
  %                  GLM. Necessary for the GLM directory.
  % :type funcFWHM: float
  %
  % :returns: :onsetFileName: (string) fullpath name of the file created.
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  onsetFileName = convertOnsetTsvToMat(opt, tsvFile);

  % move file into the FFX directory
  [~, filename, ext] = spm_fileparts(onsetFileName);
  ffxDir = getFFXdir(subID, funcFWHM, opt);
  copyfile(onsetFileName, ffxDir);

  onsetFileName = fullfile(ffxDir, [filename ext]);

end

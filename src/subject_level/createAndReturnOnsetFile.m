% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function onsetFileName = createAndReturnOnsetFile(opt, subID, tsvFile, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % onsetFileName = createAndReturnOnsetFile(opt, boldFileName, prefix, isMVPA)
  %
  % gets the tsv onset file based on the bold file name (removes any prefix)
  %
  % convert the tsv files to a mat file to be used by SPM

  onsetFileName = convertOnsetTsvToMat(opt, tsvFile);

  % move file into the FFX directory
  [~, filename, ext] = spm_fileparts(onsetFileName);
  ffxDir = getFFXdir(subID, funcFWHM, opt);
  copyfile(onsetFileName, ffxDir);

  onsetFileName = fullfile(ffxDir, [filename ext]);

end

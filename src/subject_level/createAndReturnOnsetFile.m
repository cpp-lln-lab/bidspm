% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function onsetFileName = createAndReturnOnsetFile(opt, subID, tsvFile, funcFWHM)
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

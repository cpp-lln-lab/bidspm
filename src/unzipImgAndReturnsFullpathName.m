% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  % unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  %

  [directory, filename, ext] = spm_fileparts(fullpathImgName);

  if strcmp(ext, '.gz')
    % unzip nii.gz structural file to be read by SPM
    fullpathImgName = load_untouch_nii(fullpathImgName);
    save_untouch_nii(fullpathImgName, fullfile(directory, filename));
    [unzippedFullpathImgName] = fullfile(directory, filename);

  else
    [unzippedFullpathImgName] = fullfile(directory, [filename ext]);

  end
end

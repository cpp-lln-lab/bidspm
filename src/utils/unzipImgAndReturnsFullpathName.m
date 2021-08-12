function unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % Unzips an image if necessary
  %
  % USAGE::
  %
  %   unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % :param fullpathImgName:
  % :type fullpathImgName: string
  %
  % :returns: - :unzippedFullpathImgName: (string)
  %
  % TODO:
  %
  %   - make it work on several images
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

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

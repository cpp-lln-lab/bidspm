function unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % Unzips an image if necessary
  %
  % USAGE::
  %
  %   unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % :param fullpathImgName:
  % :type fullpathImgName: string array
  %
  % :returns: - :unzippedFullpathImgName: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  if isempty(fullpathImgName)
    msg = sprintf('Provide at least one file.\n');
    errorHandling(mfilename(), 'emptyInput', msg, false, true);
  end

  for iFile = 1:size(fullpathImgName)

    [directory, filename, ext] = spm_fileparts(fullpathImgName(iFile, :));

    if strcmp(ext, '.gz')
      % unzip nii.gz structural file to be read by SPM
      fullpathImgName(iFile, :) = load_untouch_nii(fullpathImgName(iFile, :));
      save_untouch_nii(fullpathImgName(iFile, :), fullfile(directory, filename));
      unzippedFullpathImgName{iFile, 1} = fullfile(directory, filename);

    else
      unzippedFullpathImgName{iFile, 1} = fullfile(directory, [filename ext]);

    end

  end

  unzippedFullpathImgName = char(unzippedFullpathImgName);

end

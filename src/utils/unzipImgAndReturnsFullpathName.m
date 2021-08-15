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

  % TODO use argparse
  % TODO add tests

  if isempty(fullpathImgName)
    msg = sprintf('Provide at least one file.\n');
    errorHandling(mfilename(), 'emptyInput', msg, false, true);
  end

  for iFile = 1:size(fullpathImgName)

    [directory, filename, ext] = spm_fileparts(fullpathImgName(iFile, :));

    % TODO get rid of the nifti tools here.
    % we could need this to unpack .tsv.gz files for physio
    % just make sure that the unzipping is the same for matlab and octave
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

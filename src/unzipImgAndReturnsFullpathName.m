% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   unzippedFullpathImgName = unzipImgAndReturnsFullpathName(fullpathImgName)
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  %
  % :returns: - :argout1: (type) (dimension)
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

function [volumeList, nbScans] = concatenateImages(sess)
  % Concatenate images across runs.
  %
  % USAGE::
  %
  %    matFile = concatenateConfounds(sess)
  %
  %
  % :param sess: Need at least a 'multi' field.
  %              Taken from a first level GLM
  %              ``matlabbatch{1}.spm.stats.fmri_spec.sess``
  % :type  sess: structure with numel == nb of runs
  %

  % (C) Copyright 2023 bidspm developers

  if numel(sess) == 1
    volumeList = sess(1).scans{1};
    nbScans = numel(spm_vol(volumeList));
    return
  end

  files = {};
  for i = 1:numel(sess)

    % 4D image
    if size(sess(i).scans{1}, 1) == 1
      [pth, basename, ext] = fileparts(sess(i).scans{1});
      new_vols = cellstr(spm_select('ExtList', pth, [basename, ext]));
      nbScans(i) = numel(new_vols);

      % Listing of 3D volumes
    else
      new_vols = sess(i).scans(1);
      nbScans(i) = size(new_vols{1}, 1); %#ok<*AGROW>
    end

    files = cat(1, files, new_vols);

  end

  volumeList = char(files);

end

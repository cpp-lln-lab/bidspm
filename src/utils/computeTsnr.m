function [tsnrImage, volTsnr] = computeTsnr(boldImage)
  %
  % calculate temporal SNR from single run of fMRI timeseries data
  %
  % USAGE::
  %
  %   [tsnrImage, volTsnr] = computeTsnr(boldImage)
  %
  % :param boldImage: path to the 4D nifti image. The file must have a BIDS like
  %  name (example: ``key1_label1_key2-label2_suffic.nii``)
  % :type boldImage: path
  %
  % Output:
  %
  % - tsnrImage: fullpath filename of the tSNR output image
  % - volTsnr: 3D volume of the tSNR image
  %
  % Adapted from fmrwhy:
  % https://github.com/jsheunis/fMRwhy/blob/master/fmrwhy/qc/fmrwhy_qc_calculateStats.m
  %
  % Copyright 2019 Stephan Heunis

  if iscell(boldImage)
    boldImage =  char(boldImage);
  end

  % First access and reshape the functional data: 4D to 2D
  hdr = spm_vol(boldImage);
  if numel(hdr) < 10
    logger('WARNING', ['Very low number of times points.\n', ...
                       'Check that the input image is a BOLD time series.'], ...
           'id', 'lowNumTimePoints');
  end
  vol = spm_read_vols(hdr);
  [Nx, Ny, Nz, Nt] = size(vol);
  data2D = reshape(vol, Nx * Ny * Nz, Nt); % [voxels, time]
  data2D = data2D'; % [time, voxels]

  % Remove linear and quadratic trend per voxel
  data_2D_detrended = rmLowFreq(data2D, 2); % [time, voxels]

  % Calculate mean
  data_2D_mean = nanmean(data_2D_detrended); % [1, voxels]

  % Calculate standard deviation
  data_2D_stddev = std(data_2D_detrended); % [1, voxels]

  % Calculate tSNR
  tSNR_2D = data_2D_mean ./ data_2D_stddev;

  % Prepare 3D and 4D images
  volTsnr = reshape(tSNR_2D, Nx, Ny, Nz);

  try
    pth = spm_fileparts(boldImage);
    tsnrImage = bids.File(boldImage);
    tsnrImage.entities.desc = 'tsnr';
    tsnrImage = fullfile(pth, tsnrImage.filename);

    hdr = hdr(1);
    hdr.fname = tsnrImage;
    hdr.size = size(volTsnr);
    hdr.descrip = 'tSNR';

    spm_write_vol(hdr, volTsnr);

  catch
    warning(['Could not save the output tSNR image\n', ...
             'Make sure the input image has a BIDS like name.']);

  end

end

function outData = rmLowFreq(data, order)
  % Removes linear and/or quadratic trends from timeseries data
  %
  % INPUT:
  % data    - R x C matrix; R = rows = time points;
  %           C = columns = variables/parameters
  % order   - order (1,2) of regressors in design matrix
  %           order = 1: linear trend
  %           order = 2: linear trend + quadratic trend
  %
  % OUTPUT:
  % out_data
  % __________________________________________________________________________
  % Copyright (C) Stephan Heunis 2018

  % Define variables
  [r, c] = size(data);

  % Create design matrix with model regressors
  if order == 1
    X = (1:r)';
  else
    X = [(1:r)' ((1:r)').^2];
  end
  % Remove mean from design matrix
  X = X - repmat(mean(X, 1), r, 1);

  % Add constant regressor
  X = [ones(r, 1) X];

  % Solve system of linear equations
  b = pinv(X) * data;

  % Detrend data
  outData = data - X(:, 2:end) * b(2:end, :);

end

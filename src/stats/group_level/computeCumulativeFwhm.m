function fwhm = computeCumulativeFwhm(opt)
  %
  % Compute resulting fwhm when smoothing both time series and contrasts.
  %
  % USAGE::
  %
  %  fwhm = computeCumulativeFwhm(opt)
  %

  % (C) Copyright 2023 Remi Gau

  if opt.fwhm.contrast > 0
    fwhm = (opt.fwhm.func^2 + opt.fwhm.contrast^2)^0.5;
  end

end

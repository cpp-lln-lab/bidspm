function montage = setMontage(result)
  %
  % TO DO
  % - adapt so that the background image is in MNI only if opt.space is MNI
  % - add possibility to easily select mean functional or the anatomical:
  %   - at the group level or subject level
  %
  % (C) Copyright 2019 CPP_SPM developers

  if exist(result.Output.montage.background, 'file') ~= 2
    errorHandling(mfilename(), 'backgroundImageNotFound', ...
                  sprintf('Could not find the background image:\n%s', ...
                          result.Output.montage.background), ...
                  false, true);
  end

  if ~any(ismember(result.Output.montage.orientation, {'axial', 'sagittal', 'coronal'}))
    errorHandling(mfilename(), 'unknownOrientation', ...
                  sprintf(['The only allowed orientation for montage are:', ...
                           createUnorderedList({'axial', 'sagittal', 'coronal'})]), ...
                  false, true);
  end

  montage.background = {result.Output.montage.background};
  montage.orientation = result.Output.montage.orientation;
  montage.slices = result.Output.montage.slices;

end

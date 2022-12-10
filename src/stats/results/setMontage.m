function montage = setMontage(result)
  %
  % USAGE::
  %
  %   montage = setMontage(result)
  %
  %

  % (C) Copyright 2019 bidspm developers

  % TO DO
  % - adapt so that the background image is in MNI only if opt.space is IXI549Space
  % - add possibility to easily select mean functional or the anatomical:
  %   - at the group level or subject level

  if ischar(result.montage.background) && exist(result.montage.background, 'file') ~= 2
    id = 'backgroundImageNotFound';
    msg = sprintf('Could not find the background image:\n%s', ...
                  result.montage.background);
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  if ~any(ismember(result.montage.orientation, {'axial', 'sagittal', 'coronal'}))
    id = 'unknownOrientation';
    msg = sprintf(['The only allowed orientation for montage are:', ...
                   createUnorderedList({'axial', 'sagittal', 'coronal'})]);
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  montage.background = {result.montage.background};
  montage.orientation = result.montage.orientation;
  montage.slices = result.montage.slices;

end

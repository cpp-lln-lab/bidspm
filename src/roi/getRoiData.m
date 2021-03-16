% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function data = getRoiData(dataImage, mask)

  if isfield(mask, 'global')
    sts = checkRoiOrientation(dataImage, mask.global.hdr.fname);
    if sts ~= 1
      error('Images not in same space!');
    end
    clear sts;
  end

  data = spm_get_data(dataImage, mask.roi.XYZ);

end

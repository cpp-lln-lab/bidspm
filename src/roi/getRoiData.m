function data = getRoiData(dataImage, mask)
    data = spm_get_data(dataImage, mask.roi.XYZ);
end


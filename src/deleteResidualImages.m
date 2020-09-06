function deleteResidualImages(ffxDir)
    delete(fullfile(ffxDir, 'Res_*.nii'));
end

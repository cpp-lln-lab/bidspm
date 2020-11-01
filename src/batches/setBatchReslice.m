% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(referenceImg, sourceImages)
  % matlabbatch = bidsSmoothing(referenceImg, sourceImages)
  %
  % referenceImg
  %
  % sourceImages: a cell

  matlabbatch = [];
  matlabbatch{1}.spm.spatial.coreg.write.ref = {referenceImg};
  matlabbatch{1}.spm.spatial.coreg.write.source = sourceImages;

end

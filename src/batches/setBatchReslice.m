% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages)
  % matlabbatch = bidsSmoothing(referenceImg, sourceImages)
  %
  % referenceImg
  %
  % sourceImages: a cell

  printBatchName('reslicing');

  if ischar(referenceImg)
    matlabbatch{end + 1}.spm.spatial.coreg.write.ref = {referenceImg};

  elseif isstruct(referenceImg)
  end

  if iscell(sourceImages)
    matlabbatch{1}.spm.spatial.coreg.write.source = sourceImages;

  elseif isstruct(sourceImages)
  end

end

% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCoregistration(matlabbatch, ref, src, other)
  % matlabbatch = setBatchCoregistrationGeneral(matlabbatch, ref, src, other)
  %
  % ref: string
  % src: string
  % other: cell string

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref = { ref };
  matlabbatch{end}.spm.spatial.coreg.estimate.source = { src };
  matlabbatch{end}.spm.spatial.coreg.estimate.other = other;

end

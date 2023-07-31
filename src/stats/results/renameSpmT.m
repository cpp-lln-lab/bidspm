function renameSpmT(result)
  %
  % Rename the reuslts spmT (theresholed or binarized) outputted in GLM.
  %
  % USAGE::
  %
  %   renameSpmT(result)
  %

  % (C) Copyright 2023 bidspm developers
  outputFiles = spm_select('FPList', result.dir, '^spmT_[0-9].*_sub-.*nii$');

  for iFile = 1:size(outputFiles, 1)

    source = deblank(outputFiles(iFile, :));

    basename = spm_file(source, 'basename');
    split = strfind(basename, '_sub');
    bf = bids.File(basename(split + 1:end));

    target = spm_file(source, 'basename', bf.filename);

    movefile(source, target);
  end
end

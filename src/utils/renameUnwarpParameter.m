function renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [~, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  unwarpParam = spm_select('FPList', meanFuncDir, '^.*bold_uw.mat$');

  for iFile = 1:size(unwarpParam, 1)

    inputFilename = strrep(unwarpParam(iFile, :), '_uw.', '.');

    p = bids.internal.parse_filename(inputFilename);
    p.entities.label = p.suffix;
    p.suffix = 'unwarpparam';
    p.ext = '.mat';
    p.use_schema = false;
    newName = spm_file(unwarpParam(iFile, :), 'filename',  bids.create_filename(p));

    movefile(unwarpParam(iFile, :), newName);

  end

end

function rpTsvFile = convertRealignParamToTsv(rpTxtFile, opt, rmInput)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  % rp_*.txt files are organized as
  % trans x  trans y  trans z  rot x  rot y  rot z

  if nargin < 3
    rmInput = false;
  end

  content = spm_load(rpTxtFile);

  if ~strcmp(opt.bidsFilterFile.bold.suffix, 'bold')
    idx = opt.spm_2_bids.find_mapping('prefix', 'rp_');
    renamingSpec = opt.spm_2_bids.mapping(idx).name_spec;
    renamingSpec.entities.desc = bids.internal.camel_case([opt.bidsFilterFile.bold.suffix ...
                                                           ' confounds']);
    opt.spm_2_bids.mapping(idx).name_spec = renamingSpec;
  end

  rpTsvFile = spm_2_bids(rpTxtFile, opt.spm_2_bids);
  rpTsvFile = spm_file(rpTsvFile, 'path', spm_fileparts(rpTxtFile));

  nameColumns = { ...
                 'trans_x', ...
                 'trans_y', ...
                 'trans_z', ...
                 'rot_x', ...
                 'rot_y', ...
                 'rot_z'};

  for i = 1:numel(nameColumns)
    newContent.(nameColumns{i}) = content(:, i);
  end

  if exist(rpTsvFile, 'file')
    tolerant = true;
    msg = sprintf('Overwriting confound file: %s', rpTsvFile);
    errorHandling(mfilename(), 'deletingConfoundTsvFile', msg, tolerant, opt.verbosity);
    delete(rpTsvFile);
  end
  bids.util.tsvwrite(rpTsvFile, newContent);

  if rmInput
    delete(rpTxtFile);
  end

end

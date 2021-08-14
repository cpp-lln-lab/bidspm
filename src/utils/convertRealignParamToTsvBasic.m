function rpTsvFile = convertRealignParamToTsvBasic(rpTxtFile, opt, rmInput)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  % rp_*.txt files are organized as
  % trans x  trans y  trans z  rot x  rot y  rot z

  if nargin < 3
    rmInput = false;
  end

  content = spm_load(rpTxtFile);
  rpTsvFile = spm_2_bids(rpTxtFile, opt);
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

  bids.util.tsvwrite(rpTsvFile, newContent);

  if rmInput
    delete(rpTxtFile);
  end

end

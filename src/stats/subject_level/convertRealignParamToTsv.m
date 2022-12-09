function rpTsvFile = convertRealignParamToTsv(rpTxtFile, opt, rmInput)
  %
  % Convert SPM typical realignement files to a BIDs compatible TSV one.
  %
  % USAGE::
  %
  %     rpTsvFile = convertRealignParamToTsv(rpTxtFile, opt, rmInput)
  %
  %
  % :type  rpTxtFile: path
  % :param rpTxtFile: path to SPM realignement parameter txt file.
  %
  % :type  opt: structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  %
  % :type  rmInput: logical
  % :param rmInput: Optional. Default to ``false``.
  %                 If true remove original txt file.
  %
  %

  % (C) Copyright 2019 bidspm developers

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

  nameColumns = {'trans_x', ...
                 'trans_y', ...
                 'trans_z', ...
                 'rot_x', ...
                 'rot_y', ...
                 'rot_z'};

  for i = 1:numel(nameColumns)
    newContent.(nameColumns{i}) = content(:, i);
  end

  if exist(rpTsvFile, 'file')
    msg = sprintf('Overwriting confound file: %s', rpTsvFile);
    id = 'deletingConfoundTsvFile';
    logger('WARNING', msg, 'id', id, 'filename', mfilename, 'options', opt);
    delete(rpTsvFile);
  end
  bids.util.tsvwrite(rpTsvFile, newContent);

  msg = sprintf('%s --> %s\n', spm_file(rpTxtFile, 'filename'), ...
                spm_file(rpTsvFile, 'filename'));
  logger('INFO', msg, 'options', opt, 'filaneme', mfilename);

  if rmInput
    delete(rpTxtFile);
  end

end

function bidsCheckVoxelSize(opt)
  %
  % Check that all file to preprocess have the same voxel size
  %
  % USAGE::
  %
  %  status = bidsCheckVoxelSize(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %

  % (C) Copyright 2023 bidspm developers

  % If no normalisation is to be done,
  % checking that all files have the same res is not as important
  if ~ismember('IXI549Space', opt.space)
    return
  end

  if ~isempty(opt.funcVoxelDims)
    return
  end

  opt.pipeline.type = 'preproc';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  allFiles = {};
  allVoxDim = [];

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    for iTask = 1:numel(opt.taskName)

      opt.query.task = opt.taskName{iTask};

      filter = fileFilterForBold(opt, subLabel, 'stc');

      files = bids.query(BIDS, 'data', filter);

      for iFile = 1:numel(files)
        allFiles{end + 1, 1} = files{iFile}; %#ok<*AGROW>
        [subFuncDataDir, boldFilename, ext] = spm_fileparts(files{iFile});
        voxDim = getFuncVoxelDims(opt, subFuncDataDir, [boldFilename, ext]);
        allVoxDim(end + 1, :) = voxDim;
      end

    end

  end

  differentFromFirstImageRes = (allVoxDim - allVoxDim(1, :)) > 10^-3;
  if any(differentFromFirstImageRes(:))
    msg = sprintf('%s\n', 'Not all input files have the same resolution.');
    for i = 1:numel(allFiles)
      msg = [msg, sprintf('\n%s: %0.3f, %0.3f, %0.3f', ...
                          strrep(allFiles{i}, fullfile(BIDS.pth, filesep), ''), ...
                          allVoxDim(i, 1), ...
                          allVoxDim(i, 2), ...
                          allVoxDim(i, 3))];
    end
    msg = [msg, sprintf('\n\n%s\n', ...
                        ['Use the "opt.funcVoxelDims" to force the voxel dimensions', ...
                         'to have the same resolution after normalisation.'])];
    logger('ERROR', msg, ...
           'options', opt, ...
           'filename', mfilename(), ...
           'id', 'differentVoxelSize');
  end

end

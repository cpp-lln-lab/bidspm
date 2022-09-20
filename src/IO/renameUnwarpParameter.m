function renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 bidspm developers

  if opt.anatOnly
    return
  end

  opt = set_spm_2_bids_defaults(opt);

  for iTask = 1:numel(opt.taskName)

    unwarpParam = spm_select('FPListRec', BIDS.pth, ...
                             ['^.*sub-' subLabel '.*_task-' opt.taskName{iTask} '.*_bold_uw.mat$']);

    for iFile = 1:size(unwarpParam, 1)

      newFilename = spm_2_bids(unwarpParam(iFile, :), opt.spm_2_bids);

      outputFile = spm_file(unwarpParam(iFile, :), 'filename', newFilename);

      if ~isempty(unwarpParam(iFile, :))
        movefile(unwarpParam(iFile, :), outputFile);
      end

    end

  end

end

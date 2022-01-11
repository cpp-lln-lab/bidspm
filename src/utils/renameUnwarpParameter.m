function renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  if opt.anatOnly
    return
  end

  for iTask = 1:numel(opt.taskName)

    unwarpParam = spm_select('FPListRec', BIDS.pth, ...
                             ['^.*sub-' subLabel '.*_task-' opt.taskName{iTask} '.*_bold_uw.mat$']);

    for iFile = 1:size(unwarpParam, 1)

      inputFilename = strrep(unwarpParam(iFile, :), '_uw.', '.');

      p = bids.internal.parse_filename(inputFilename);
      p.entities.label = p.suffix;
      p.suffix = 'unwarpparam';
      p.ext = '.mat';

      bidsFile = bids.File(p);

      newName = spm_file(unwarpParam(iFile, :), 'filename',  bidsFile.filename);

      if ~isempty(unwarpParam(iFile, :))
        movefile(unwarpParam(iFile, :), newName);
      end

    end

  end

end

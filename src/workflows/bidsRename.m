function bidsRename(opt)
  %
  % (C) Copyright 2019 CPP_SPM developers

  createdFiles = {};

  opt = set_spm_2_bids_defaults(opt);

  opt.dir.input = opt.dir.preproc;
  [BIDS, opt] = setUpWorkflow(opt, 'renaming to BIDS derivatives');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    query = opt.query;
    query.sub = subLabel;

    data = bids.query(BIDS, 'data', query);

    for iFile = 1:size(data, 1)

      [new_filename, ~, json] = spm_2_bids(data{iFile}, opt.spm_2_bids);

      msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), new_filename);
      printToScreen(msg, opt);

      if ismember(new_filename, createdFiles)
        warning('file already created');
      end

      createdFiles{end + 1, 1} = new_filename;

      if ~opt.dryRun && ~strcmp(new_filename, spm_file(data{iFile}, 'filename'))

        % TODO write test for this
        if ~exist(new_filename, 'file')
          movefile(data{iFile}, spm_file(data{iFile}, 'filename', new_filename));
        else
          msg = sprintf('This file already exists. Will not overwrite.\n\t%s\n', ...
                        new_filename);
          error_handling(mfilename(), 'fileAlreadyExist', msg, true, opt.verbosity);
        end

      end
    end

  end

end

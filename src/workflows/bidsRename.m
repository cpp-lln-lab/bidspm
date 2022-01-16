function bidsRename(opt)
  %
  % Renames SPM output into BIDS compatible files.
  %
  % USAGE::
  %
  %   bidsRename(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % See the spm_2_bids submodule and ``defaults.set_spm_2_bids_defaults``
  % for more info.
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  if ~opt.rename
    return
  end

  createdFiles = {};

  if not(isfield(opt, 'spm_2_bids'))
    opt = set_spm_2_bids_defaults(opt);
  end

  opt.dir.input = opt.dir.preproc;
  [BIDS, opt] = setUpWorkflow(opt, 'renaming to BIDS derivatives');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    filter = opt.query;
    filter.sub = subLabel;

    data = bids.query(BIDS, 'data', filter);

    for iFile = 1:size(data, 1)

      % TODO: take care of metadata in json
      [new_filename, ~, json] = spm_2_bids(data{iFile}, opt.spm_2_bids);

      msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), new_filename);
      printToScreen(msg, opt);

      if ~opt.dryRun && ~strcmp(new_filename, spm_file(data{iFile}, 'filename'))

        % TODO write test for this
        if exist(new_filename, 'file') || ismember(new_filename, createdFiles)
          msg = sprintf('This file already exists. Will not overwrite.\n\t%s\n', ...
                        new_filename);
          errorHandling(mfilename(), 'fileAlreadyExist', msg, true, opt.verbosity);

        else
          movefile(data{iFile}, spm_file(data{iFile}, 'filename', new_filename));

        end

      end

      createdFiles{end + 1, 1} = new_filename;

    end

  end

  cleanUpWorkflow(opt);

end

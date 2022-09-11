function bidsRename(opt)
  %
  % Renames SPM output into BIDS compatible files.
  %
  % USAGE::
  %
  %   bidsRename(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % See the spm_2_bids submodule and ``defaults.set_spm_2_bids_defaults``
  % for more info.
  %
  %
  % (C) Copyright 2019 bidspm developers

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

      [newFilename, ~, json] = spm_2_bids(data{iFile}, opt.spm_2_bids);

      outputFile = spm_file(data{iFile}, 'filename', newFilename);

      % only continue if the file has actually been renamed
      if ~strcmp(outputFile, data{iFile})

        json = updateSource(json, data{iFile}, opt);

        msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), newFilename);
        printToScreen(msg, opt);

        renameFileAndUpdateMetadata(opt, data{iFile}, newFilename, json, createdFiles);

        createdFiles{end + 1, 1} = newFilename;

      end

    end

  end

  cleanUpWorkflow(opt);

end

function renameFileAndUpdateMetadata(opt, data, newFilename, json, createdFiles)

  outputFile = spm_file(data, 'filename', newFilename);

  if opt.dryRun
    return
  end

  % TODO write test for this
  if exist(outputFile, 'file') || ismember(newFilename, createdFiles)

    msg = sprintf('This file already exists. Will not overwrite.\n\t%s\n', ...
                  newFilename);
    errorHandling(mfilename(), 'fileAlreadyExist', msg, true, opt.verbosity);

  else

    movefile(data, outputFile);

    if ~isempty(json.filename)
      bids.util.jsonencode(fullfile(fileparts(data), json.filename), ...
                           json.content);
    end

  end

end

function json = updateSource(json, data, opt)
  %
  % deal with prefixes not covered by spm_2_bids
  %

  bf = bids.File(data, 'verbose', opt.verbosity > 0, 'use_schema', false);

  if startsWith(bf.prefix, 'std_')

    bf.prefix = bf.prefix(5:end);

    % call spm_2_bids what is the filename from the previous step
    new_filename = spm_2_bids(bf.filename, opt.spm_2_bids, opt.verbosity > 0);

    json.content.Sources{1, 1} = fullfile(bf.bids_path, new_filename);

  end
end

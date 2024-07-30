function createdFiles = bidsRename(opt)
  %
  % Renames SPM output into BIDS compatible files.
  %
  % USAGE::
  %
  %   bidsRename(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %
  % See the spm_2_bids submodule and :func:`set_spm_2_bids_defaults`
  % for more info.
  %
  %

  % (C) Copyright 2019 bidspm developers

  if ~opt.rename.do
    return
  end

  createdFiles = {};

  if ~(isfield(opt, 'spm_2_bids'))
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

        json.content.SpmFilename = spm_file(data{iFile}, 'filename');

        msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), newFilename);
        printToScreen(msg, opt);

        renameFileAndUpdateMetadata(opt, data{iFile}, newFilename, json, createdFiles);

        createdFiles{end + 1, 1} = spm_file(data{iFile}, ...
                                            'filename', ...
                                            newFilename); %#ok<*AGROW>

      end

    end

  end

end

function renameFileAndUpdateMetadata(opt, data, newFilename, json, createdFiles)

  outputFile = spm_file(data, 'filename', newFilename);

  if opt.dryRun
    return
  end

  if ~opt.rename.overwrite && exist(outputFile, 'file') || ...
      ismember(newFilename, createdFiles)

    msg = sprintf('This file already exists. Will not overwrite.\n\t%s\n', ...
                  newFilename);
    id = 'fileAlreadyExist';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

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

  if bids.internal.starts_with(bf.prefix, 'std_')

    bf.prefix = bf.prefix(5:end);

    % call spm_2_bids what is the filename from the previous step
    new_filename = spm_2_bids(bf.filename, opt.spm_2_bids, opt.verbosity > 0);

    json.content.Sources{1, 1} = fullfile(bf.bids_path, new_filename);

  end
end

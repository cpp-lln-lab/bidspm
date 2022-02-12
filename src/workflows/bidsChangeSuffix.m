function bidsChangeSuffix(varargin)
  %
  % USAGE::
  %
  %   bidsChangeSuffix(opt, newSuffix, 'filter', struct([]), 'force', false)
  %
  % :param opt: BIDS input dataset must be defined in ``opt.dir.input``;
  % To test the output, set ``opt.dryRun`` to ``true``.
  % :type opt: structure
  %
  % :param newSuffix: TODO: add checks on newSuffix to make sure it only contains [a-zA-Z0-9]
  % :type newSuffix: string
  %
  % :param filter: structure to decide which files to include. Default:
  % ``struct([])`` for no filter
  % :type filter: structure
  %
  % :param force: If set to ``true`` it will overwrite already existing files. Default: ``false``
  % :type force: boolean
  %
  %
  % EXAMPLE::
  %
  %     opt.dir.input = path_to_dataset;
  %     opt.dryRun = true;
  %
  %     newSuffix = 'vaso';
  %
  %     filter = struct('suffix', 'bold');
  %
  %     bidsChangeSuffix(opt, newSuffix, ...
  %                     'filter', filter, ...
  %                     'force', false)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'newSuffix', @ischar);
  addParameter(p, 'filter', struct([]), @isstruct);
  addParameter(p, 'force', false, @islogical);

  parse(p, varargin{:});

  opt = p.Results.opt;
  newSuffix = p.Results.newSuffix;
  filter = p.Results.filter;
  force = p.Results.force;

  [BIDS, opt] = setUpWorkflow(opt, 'changing suffix', opt.dir.input);

  if isempty(filter)
    data = bids.query(BIDS, 'data');
    metadata = bids.query(BIDS, 'metadata');
    metafiles = bids.query(BIDS, 'metafiles');
  else
    data = bids.query(BIDS, 'data', filter);
    metadata = bids.query(BIDS, 'metadata', filter);
    metafiles = bids.query(BIDS, 'metafiles', filter);
  end

  createdFiles = {};

  for iFile = 1:size(data, 1)

    specification.suffix = newSuffix;
    % FYI renameFile was part of CPP ROI
    % Will be replaced by some yet to come bids matlab function
    [newName, outputFile] = renameFile(data{iFile}, specification);

    msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), newName);
    printToScreen(msg, opt);

    if exist(outputFile, 'file') || ismember(newName, createdFiles)

      msg = sprintf('This file already exists.\n\t%s\n', newName);
      errorHandling(mfilename(), 'fileAlreadyExist', msg, true, opt.verbosity);

      if ~opt.dryRun && force
        % actually rename file and createa JSON side car
        movefile(data{iFile}, outputFile);
        bf = bids.File(outputFile);
        json_file = fullfile(fileparts(data{iFile}), bf.json_filename);
        bids.util.jsonencode(json_file, metadata{iFile});
        
      end

    elseif ~opt.dryRun
      movefile(data{iFile}, outputFile);
      bf = bids.File(outputFile);
      json_file = fullfile(fileparts(data{iFile}), bf.json_filename);
      bids.util.jsonencode(json_file, metadata{iFile});
      
    end

    createdFiles{end + 1, 1} = newName;

  end

  cleanUpWorkflow(opt);
  
  % remove old side car JSON files
  if ~opt.dryRun
    for i = 1:numel(metafiles)
      if ischar(metafiles{i})
        metafiles{i} = cellstr(metafiles{i});
      end
      for meta = 1:numel(metafiles{i})
        if exist(metafiles{i}{meta}, 'file')
          printToScreen(sprintf('Deleting %s\n', metafiles{i}{meta}), opt);
          delete(metafiles{i}{meta});
        end
      end
    end
  end

end

function [newName, outputFile] = renameFile(inputFile, specification)
  %
  % Renames a BIDS valid file into another BIDS valid file given some
  % specificationification.
  %
  % USAGE::
  %
  %   [newName, outputFile] = renameFile(inputFile, specificationification)
  %
  % :param inputFile: better if fullfile path
  % :type inputFile: string
  % :param specificationification: structure specificationifying the details of the new name
  %                       The structure content must resemble that of the
  %                       output of bids.internal.parse_filename
  % :type specificationification: structure
  %
  % (C) Copyright 2021 CPP ROI developers

  bf = bids.File(inputFile, 'use_schema', false);

  if isfield(specification, 'prefix')
    bf.suffix = specification.prefix;
  end
  if isfield(specification, 'suffix')
    bf.suffix = specification.suffix;
  end
  if isfield(specification, 'ext')
    bf.extension = specification.ext;
  end
  if isfield(specification, 'entities')
    entities = fieldnames(specification.entities);
    for i = 1:numel(entities)
      bf = bf.set_entity(entities{i}, ...
                         bids.internal.camel_case(specification.entities.(entities{i})));
    end
  end
  if isfield(specification, 'entity_order')
    bf = bf.reorder_entities(specification.entity_order);
  end

  bf = bf.update;

  newName = bf.filename;
  outputFile = spm_file(inputFile, 'filename', newName);

end

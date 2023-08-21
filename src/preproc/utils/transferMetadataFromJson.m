function updatedFiles = transferMetadataFromJson(createdFiles, extraMetadata)
  % Add repetition time and slice timing metadata
  % to prepocessed or smoothed files metadata
  % by reading them from the Sources files mentioned
  % in the sidecar JSON.
  %
  % USAGE:
  %
  % .. code_block: matlab
  %
  %     transferMetadataFromJson(createdFiles, extraMetadata)
  %
  % :type  createdFiles: cellstr
  % :param createdFiles: Files renamed by spm_2_bids
  %
  % :type  extraMetadata: struct
  % :param extraMetadata: Extra metadata to add.
  %

  % (C) Copyright 2023 bidspm developers

  if nargin < 2
    extraMetadata = struct();
  end

  updatedFiles = {};

  for iFile = 1:numel(createdFiles)

    bf = bids.File(createdFiles{iFile});
    if ~strcmp(bf.suffix, 'bold')
      continue
    end
    if isfield(bf.entities, 'desc') && ...
            any(ismember({'mean', 'stc'}, bf.entities.desc))
      continue
    end
    if isempty(bf.metadata) || isempty(bf.metadata_files)
      continue
    end

    isToDo = @(x) ~cellfun('isempty', strfind(x, 'TODO')); %#ok<STRCL1>
    hasCellField = @(x, y) isfield(x.metadata, y) && ...
                           ~isempty(x.metadata.(y)) && ...
                           iscell(x.metadata.(y));
    if hasCellField(bf, 'Sources') && ~all(isToDo(bf.metadata.Sources))
      sourceFiles = bf.metadata.Sources;
    elseif hasCellField(bf, 'RawSources') && noAllToDo(bf.metadata.RawSources)
      sourceFiles = bf.metadata.RawSources;
    else
      continue
    end

    if isempty(bf.modality)
      bf.modality = guess_modality(bf);
    end

    bidsRoot = strrep(bf.path, fullfile(bf.bids_path, bf.filename), '');

    metadataToTransfer = collectMetadataToTransfer(sourceFiles, bidsRoot);
    metadataToTransfer = setFields(metadataToTransfer, extraMetadata, true);

    bf = transferMetadata(bf, metadataToTransfer);

    bf.metadata_write();

    updatedFiles{end + 1} = fullfile(fileparts(bf.path), bf.json_filename); %#ok<*AGROW>

  end

end

function metadataToTransfer = collectMetadataToTransfer(sourceFiles, bidsRoot)
  metadataToTransfer = struct('RepetitionTime', [], ...
                              'SliceTimingCorrected', [], ...
                              'StartTime', []);

  fields = fieldnames(metadataToTransfer);

  for iSource = 1:numel(sourceFiles)
    src = bids.File(fullfile(bidsRoot, sourceFiles{iSource}));

    for iField = 1:numel(fields)
      field_ = fields{iField};

      if isfield(src.metadata, field_)
        value = src.metadata.(field_);
      else
        value = nan;
      end

      if strcmp(field_, 'StartTime') && isnan(value)
        continue
      end

      metadataToTransfer.(field_)(end + 1) = value;
    end

  end
end

function bf = transferMetadata(bf, metadataToTransfer)
  fields = fieldnames(metadataToTransfer);

  for iField = 1:numel(fields)
    field_ = fields{iField};
    value = unique(metadataToTransfer.(field_));

    value(isnan(value)) = [];

    if numel(value) > 1
      % TODO warning as source file should not have conflicting info
      continue
    end

    if ~strcmp(field_, 'SliceTimingCorrected') && isempty(value)
      continue
    end

    bf.metadata.(field_) = value;

    if strcmp(field_, 'SliceTimingCorrected')
      if isempty(value) || value == 0
        value = false;
      elseif value == 1
        value = true;
      end
      bf.metadata.(field_) = value;
    end
  end
end

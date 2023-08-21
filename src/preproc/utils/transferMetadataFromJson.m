function updatedFiles = transferMetadataFromJson(createdFiles)
  % Add repetition time and slice timing metadata
  % to prepocessed or smoothed files metadata
  % by reading them from the Sources files mentioned
  % in the sidecar JSON.
  %
  % USAGE:
  %
  % .. code_block: matlab
  %
  %     transferMetadataFromJson(createdFiles)
  %
  % :type  createdFiles: cellstr
  % :param createdFiles: Files renamed by spm_2_bids
  %

  % (C) Copyright 2023 bidspm developers

  updatedFiles = {};

  for iFile = 1:numel(createdFiles)

    bf = bids.File(createdFiles{iFile});
    if ~strcmp(bf.suffix, 'bold')
      continue
    end
    if isempty(bf.metadata) || isempty(bf.metadata_files)
      continue
    end
    if ~isfield(bf.metadata, 'Sources') || isempty(bf.metadata.Sources)
      continue
    end

    if isempty(bf.modality)
      bf.modality = guess_modality(bf);
    end
    bidsRoot = strrep(bf.path, fullfile(bf.bids_path, bf.filename), '');

    sourceFiles = bf.metadata.Sources;

    metadataToTransfer = collectMetadataToTransfer(sourceFiles, bidsRoot);

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
    metadataToTransfer.(field_) = unique(metadataToTransfer.(field_));

    if numel(metadataToTransfer.(field_)) > 1
      % TODO warning as source file should not have conflicting info
      continue
    end
    if isempty(metadataToTransfer.(field_))
      continue
    end

    bf.metadata.(field_) = metadataToTransfer.(field_);

    if strcmp(field_, 'SliceTimingCorrected')
      if isnan(metadataToTransfer.SliceTimingCorrected) || ...
              metadataToTransfer.SliceTimingCorrected == 0
        value = false;
      elseif metadataToTransfer.SliceTimingCorrected == 1
        value = true;
      end
      bf.metadata.(field_) = value;
    end
  end
end

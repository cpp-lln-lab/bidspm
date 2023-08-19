function transferMetadata(opt, createdFiles, unRenamedFiles, srcMetadata)
  % Add repetition time and slice timing metadata
  % to prepocessed or smoothed files metadata.
  %
  % USAGE:
  %
  % .. code_block: matlab
  %
  %     transferMetadata(opt, createdFiles, unRenamedFiles, srcMetadata)
  %
  % :type  opt: structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  %
  % :type  createdFiles: cellstr
  % :param createdFiles: Files renamed by spm_2_bids
  %
  % :type  unRenamedFiles: cell of cell of cellstr
  % :param unRenamedFiles: Files before renaming.
  %                        Format is cell{iSub}{batchIdx}{outputFileIdx}
  %                        See :func:`filesToTransferMetadataTo`
  %
  % :type  srcMetadata: struct
  % :param srcMetadata: Metadata of input files.
  %                     Format is srcMetadata(iSub)
  %

  % (C) Copyright 2023 bidspm developers
  metadataToTransfer = fieldnames(srcMetadata);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    for iFile = 1:numel(createdFiles)

      bf = bids.File(createdFiles{iFile});
      if ~strcmp(bf.suffix, 'bold') || ~strcmp(bf.entities.sub, subLabel)
        continue
      end

      jsonFile = spm_file(createdFiles{iFile}, 'ext', '.json');
      if exist(jsonFile, 'file')

        metadata = bids.util.jsondecode(jsonFile);
        for i = 1:numel(unRenamedFiles{iSub})
          idx = ~cellfun('isempty', ...
                         strfind(unRenamedFiles{iSub}{i}, ...
                                 metadata.SpmFilename));
          if ~any(idx)
            continue
          end
          for j = 1:numel(metadataToTransfer)
            newMetadata = srcMetadata(iSub).(metadataToTransfer{j})(idx);
            metadata.(metadataToTransfer{j}) = newMetadata;
          end

          bids.util.jsonencode(jsonFile, metadata);
        end

      end

    end
  end
end

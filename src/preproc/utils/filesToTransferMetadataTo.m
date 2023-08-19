function output = filesToTransferMetadataTo(batchOutput, batchToTransferMetadataTo)
  % List files in output of batches to transfer metadata to.
  %
  % USAGE:
  %
  % .. code_block: matlab
  %
  %     output = filesToTransferMetadataTo(batchOutput, batchToTransferMetadataTo)
  %
  % :type  batchOutput: structure
  % :param batchOutput: Batches output after being run.
  %                     See :func:`saveAndRunWorkflow`.
  %
  % :type  batchToTransferMetadataTo: array
  % :param batchToTransferMetadataTo: indices of batch of interest
  %
  % :rtype output: cell of cellstr
  %                Files before renaming.
  %                Format is cell{batchIdx}{outputFileIdx}
  %

  % (C) Copyright 2023 bidspm developers
  batchOutput = batchOutput(batchToTransferMetadataTo);
  output = {};

  for i = 1:numel(batchOutput)

    if isfield(batchOutput{i}, 'files')
      files = batchOutput{i}.files;
    elseif isfield(batchOutput{i}, 'rfiles')
      files = batchOutput{i}.rfiles;
    end

    paths = spm_file(files, 'path');
    files = spm_file(files, 'basename');

    [files, kept] = unique(files);
    paths = paths(kept);

    idx = ~cellfun('isempty', strfind(files, 'mean'));
    paths(idx) = [];
    files(idx) = [];

    files = spm_file(files, 'path', paths);
    output{end + 1} = spm_file(files, 'ext', '.nii'); %#ok<*AGROW>
  end
end

function renameOutputResults(opt, result, subLabel)
  %
  % we create new name for the nifti output by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file
  %
  % also rename PNG and labels activations
  %

  % (C) Copyright 2023 bidspm developers
  if nargin < 3
    subLabel = '';
  end

  if result.binary || result.threshSpm
    renameSpmT(result);
  end

  if result.nidm
    % TODO currently name of nidm file does not include
    %   the label of the contrast that was used to generate it.
    renameNidm(opt, result, subLabel);
  end

  if result.png
    % TODO currently name of PNG file does not include
    %   the label of the contrast that was used to generate it.
    renamePngCsvResults(opt, result, '.png', subLabel);
  end

  if result.csv
    % TODO currently name of CSV file does not include
    %   the label of the contrast that was used to generate it.

    renamePngCsvResults(opt, result, '.csv', subLabel);

    if isMni(result.space)

      csvFiles = spm_select('FPList', result.dir, '^.*results.csv$');

      for iFile = 1:size(csvFiles, 1)
        source = deblank(csvFiles(iFile, :));
        labelActivations(source, 'atlas', result.atlas);
      end
    end

  end

end

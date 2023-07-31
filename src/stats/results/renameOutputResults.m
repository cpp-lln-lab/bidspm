function renameOutputResults(opt, results, subLabel)
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

  for i = 1:numel(results)

    if iscell(results)
      result = results{i};
    elseif isstruct(results)
      result = results(i);
    end

    if result.binary || result.threshSpm
      renameSpmT(result);
    end

    if result.nidm
      renameNidm(opt, result, subLabel);
    end

    if result.png
      renamePngCsvResults(opt, result, '.png', subLabel);
    end

    if result.csv

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

end

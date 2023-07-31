function renamePngCsvResults(opt, result, ext, subLabel)
  %
  % Rename the reuslts png and csv files to a bids friendly filename.
  %
  % USAGE::
  %
  %   renamePngCsvResults(opt, result, ext, subLabel)
  %

  % (C) Copyright 2023 bidspm developers
  if nargin < 4
    subLabel = '';
  end

  result.label = subLabel;
  spec = returnResultNameSpec(opt, result);
  spec.suffix = 'results';
  spec.ext = ext;

  files = spm_select('FPList', result.dir, ['^spm_.*[0-9]{3}' ext '$']);

  for iFile = 1:size(files, 1)

    source = deblank(files(iFile, :));

    if strcmp(ext, '.png')
      basename =  spm_file(source, 'basename');
      label =  regexp(basename, '[0-9]{3}$', 'match');
      spec.entities.page = label{1};
    end
    bf = bids.File(spec, 'use_schema', false);
    bf = bf.reorder_entities();
    bf = bf.update;
    target = fullfile(result.dir, bf.filename);

    movefile(source, target);

  end

end

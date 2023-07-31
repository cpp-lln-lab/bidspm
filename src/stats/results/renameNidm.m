function renameNidm(opt, result, subLabel)
  %
  % removes the _XXX suffix before the nidm extension.

  % (C) Copyright 2023 bidspm developers
  if nargin < 3
    subLabel = '';
  end

  result.label = subLabel;
  spec = returnResultNameSpec(opt, result);
  spec.suffix = 'nidm';
  spec.ext = '.zip';

  files = spm_select('FPList', result.dir, '^spm_[0-9]{4}.nidm.zip$');

  for iFile = 1:size(files, 1)
    source = deblank(files(iFile, :));
    bf = bids.File(spec, 'use_schema', false);
    bf = bf.reorder_entities();
    bf = bf.update;
    target = fullfile(result.dir, bf.filename);
    movefile(source, target);
  end

end

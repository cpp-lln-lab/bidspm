function matlabbatch = setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, imgToResample)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchNormalize(matlabbatch, deformField, subLabel, imgToResample)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  %
  % :returns: - :matlabbatch: (structure)
  %

  % (C) Copyright 2022 bidspm developers

  if ischar(imgToResample)
    imgToResample = cellstr(imgToResample);
  end

  % locate 1 deformation field
  filter = struct('sub', subLabel, ...
                  'suffix', opt.bidsFilterFile.xfm.suffix, ...
                  'to', opt.bidsFilterFile.xfm.to, ...
                  'mode', 'image', ...
                  'extension', '.nii');

  if isfield(opt.bidsFilterFile.t1w, 'ses')
    filter.ses = opt.bidsFilterFile.t1w.ses;
  end

  deformationField = bids.query(BIDS, 'data', filter);

  if isempty(deformationField)
    msg = sprintf('No deformation field found for query %s', ...
                  bids.internal.create_unordered_list(filter));
    id = 'noDeformationField';
    logger('WARNING', msg, ...
           'options', opt, ...
           'id', id, ...
           'filename', mfilename());
    return
  end

  if numel(deformationField) > 1
    msg = sprintf(['Too deformation field for subject %s:', ...
                   '\n%s', ...
                   '\n\nSpecify the target session in "opt.bidsFilterFile.t1w.ses"'], ...
                  subLabel, ...
                  bids.internal.create_unordered_list(deformationField));
    id = 'tooManyDeformationField';
    logger('ERROR', msg, ...
           'options', opt, ...
           'id', id, ...
           'filename', mfilename());
  end

  matlabbatch{end + 1}.spm.spatial.normalise.write.subj.def(1) = deformationField;
  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox = nan(1, 3);
  matlabbatch{end}.spm.spatial.normalise.write.subj.resample = imgToResample;
  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);

end

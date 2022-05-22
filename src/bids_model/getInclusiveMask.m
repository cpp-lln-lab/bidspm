function mask = getInclusiveMask(opt, nodeName)
  %
  % use the mask specified in the BIDS stats model
  %
  % if none is specified and we are in MNI space
  % we use the Intra Cerebal Volume SPM mask
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if nargin < 2
    mask = opt.model.bm.getModelMask();
  else
    mask = opt.model.bm.getModelMask('Name', nodeName);
  end

  if isempty(mask) && ...
          (~isempty(strfind(opt.space{1}, 'MNI')) || strcmp(opt.space, 'IXI549Space'))
    mask = spm_select('FPList', fullfile(spm('dir'), 'tpm'), 'mask_ICV.nii');
  end

  if ~isempty(mask)
    validationInputFile([], mask);
  end

end

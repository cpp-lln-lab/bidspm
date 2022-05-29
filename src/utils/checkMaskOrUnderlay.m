function image = checkMaskOrUnderlay(image, opt, type)
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if ischar(image)

    if isempty(image) || ~exist(image, 'file')

      msg = 'Could not find specified file for mask/montage.';

      if isMni(opt.space)

        if ismember(lower(type), {'underlay', 'background'})
          image = spm_select('FPList', fullfile(spm('dir'), 'canonical'), 'avg305T1.nii');
          msg = [msg '\nWill use SPM MNI default image'];

        elseif strcmpi(type, 'mask')
          image = spm_select('FPList', fullfile(spm('dir'), 'tpm'), 'mask_ICV.nii');
          msg = [msg '\nWill use SPM intracerebral volume mask'];

        end

      end

      tolerant = true;
      msg = sprintf(msg);
      id = 'missingMaskOrUnderlay';
      errorHandling(mfilename(), id, msg, tolerant, opt.verbosity);

    end

  end

end

% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchComputeVDM(matlabbatch, fmapType, refImage)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % matlabbatch = setBatchComputeVDM(type)
  %
  % adapted from spmup get_FM_workflow.m (@ commit
  % 198c980d6d7520b1a996f0e56269e2ceab72cc83)

  switch lower(fmapType)
    case 'phasediff'
      matlabbatch{end + 1}.spm.tools.fieldmap.calculatevdm.subj(1).data.presubphasemag.phase = '';
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).data.presubphasemag.magnitude = '';

    case 'phase&mag'
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortphase = '';
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortmag = '';
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longphase = '';
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longmag = '';

    otherwise
      error('This type of field map is not handled: %s', fmapType);
  end

  UF = struct( ...
              'method', 'Mark3D', ...
              'fwhm', 10, ...
              'pad', 0, ...
              'ws', 1);

  MF = struct( ...
              'fwhm', 5, ...
              'nerode', 2, ...
              'ndilate', 4, ...
              'thresh', 0.5, ...
              'reg', 0.02);

  defaultsval = struct( ...
                       'et', [NaN NaN], ...
                       'maskbrain', 1, ...
                       'blipdir', 1, ...
                       'tert', '', ...
                       'epifm', 0, ... % can be changed
                       'ajm', 0, ...
                       'uflags', UF, ...
                       'mflags', MF);

  fieldMapTemplate = spm_select( ...
                                'FPList', ...
                                fullfile( ...
                                         spm('dir'), ...
                                         'toolbox', ...
                                         'FieldMap'), ...
                                '^T1.nii$');
  defaultsval.mflags.template = { fieldMapTemplate };

  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval = defaultsval;

  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).session.epi = {refImage};
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).matchvdm = 1;
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).sessname = 'vdm-';
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).writeunwarped = 1;
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).anat = '';
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj(1).matchanat = 0;

end

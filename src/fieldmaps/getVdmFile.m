% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % returns the voxel displacement map associated with a given bold file
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

  vdmFile = '';

  fragments = bids.internal.parse_filename(boldFilename);

  if ~isfield(fragments, 'ses')
    fragments.ses = '';
  end

  modalities = spm_BIDS(BIDS, 'modalities', ...
                        'sub', fragments.sub, ...
                        'ses', fragments.ses);

  if ~opt.ignoreFieldmaps && any(ismember('fmap', modalities))

    fmapFiles = spm_BIDS(BIDS, 'data', ...
                         'modality', 'fmap', ...
                         'sub', fragments.sub, ...
                         'ses', fragments.ses);

    fmapMetadata = spm_BIDS(BIDS, 'metadata', ...
                            'modality', 'fmap', ...
                            'sub', fragments.sub, ...
                            'ses', fragments.ses);

    for  iFile = 1:size(fmapFiles, 1)

      intendedFor = fmapMetadata{iFile}.IntendedFor;

      if strfind(intendedFor, boldFilename) %#ok<STRIFCND>
        [pth, filename, ext] = spm_fileparts(fmapFiles{iFile});
        vdmFile = validationInputFile(pth, [filename ext], 'vdm5_sc');
        break
      end

    end

  end

end

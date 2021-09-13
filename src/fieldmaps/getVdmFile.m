function vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % returns the voxel displacement map associated with a given bold file
  %
  % USAGE::
  %
  %   vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param boldFilename:
  % :type opt: string
  %
  % :returns: - :vdmFile: (string)
  %
  % (C) Copyright 2020 CPP_SPM developers

  vdmFile = '';

  p = bids.internal.parse_filename(boldFilename);
  entities = p.entities;

  if ~isfield(entities, 'ses')
    entities.ses = '';
  end

  modalities = bids.query(BIDS, 'modalities', ...
                          'sub', entities.sub, ...
                          'ses', entities.ses);

  if opt.useFieldmaps && any(ismember('fmap', modalities))
    % We loop through the field maps and find the one that is intended for this
    % bold file by reading from the metadata
    %
    % We break the loop when the file has been found

    fmapFiles = bids.query(BIDS, 'data', ...
                           'modality', 'fmap', ...
                           'sub', entities.sub, ...
                           'ses', entities.ses);

    fmapMetadata = bids.query(BIDS, 'metadata', ...
                              'modality', 'fmap', ...
                              'sub', entities.sub, ...
                              'ses', entities.ses);

    for  iFile = 1:size(fmapFiles, 1)

      intendedFor = fmapMetadata{iFile}.IntendedFor;

      if strfind(intendedFor, boldFilename) %#ok<STRIFCND>
        [pth, filename, ext] = spm_fileparts(fmapFiles{iFile});
        vdmFile = validationInputFile(pth, [filename ext], 'vdm5_sc');
        break
      end

    end

  end

  if isempty(vdmFile)
    msg = sprintf('No voxel displacement map associated with: \n %s', boldFilename);
    errorHandling(mfilename(), 'noVDM', msg, true, opt.verbosity);
  end

end

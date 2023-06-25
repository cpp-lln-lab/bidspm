function vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % returns the voxel displacement map associated with a given bold file
  %
  % USAGE::
  %
  %   vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type  opt: structure
  %
  % :param boldFilename:
  % :type  boldFilename: path
  %
  % :returns: - :vdmFile: (string)
  %

  % (C) Copyright 2020 bidspm developers

  vdmFile = '';

  bf = bids.File(boldFilename);
  entities = bf.entities;

  if ~isfield(entities, 'ses')
    entities.ses = '';
  end

  modalities = bids.query(BIDS, 'modalities', ...
                          'sub', entities.sub, ...
                          'ses', entities.ses);

  if opt.useFieldmaps && any(ismember('fmap', modalities))
    % We loop through the field maps and find one that is intended for
    % this bold file by reading from the metadata
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

      if isfield(fmapMetadata{iFile}, 'IntendedFor')

        intendedFor = fmapMetadata{iFile}.IntendedFor;

        vdmFile = returnVdmFilename(opt, intendedFor, boldFilename, fmapFiles{iFile});

        if ~isempty(vdmFile)
          break
        end

      end

    end

  end

  if isempty(vdmFile) && any(ismember('fmap', modalities))
    msg = sprintf('No voxel displacement map associated with: \n %s', boldFilename);
    id = 'noVDM';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
  end

end

function vdmFile = returnVdmFilename(opt, intendedFor, boldFilename, fmapFile)

  vdmFile = '';

  if strfind(intendedFor, boldFilename) %#ok<STRIFCND>

    [pth, filename, ext] = spm_fileparts(fmapFile);

    try

      vdmFile = validationInputFile(pth, [filename ext], 'vdm5_sc');

      return

    catch ME

      if strcmp(ME.identifier, 'validationInputFile:nonExistentFile')

        msg = ['Voxel displacement map missing.\n', ...
               'Creating voxel displacement maps is work in progress.\n', ...
               'This is known issue. Skipping for now.'];
        id = 'missingVdm';
        logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

        return

      else

        rethrow(ME);

      end

    end

  end

end

function roiBidsFile = buildIndividualSpaceRoiFilename(deformationField, roiFilename)
  %
  % Creates a roi filename in individual space given a roi filename and a deformation field
  %
  % USAGE::
  %
  %     roiBidsFile = buildIndividualSpaceRoiFilename(deformationField, roiFilename)
  %
  % :param deformationField: path to deformation field image.
  % :type  deformationField: path
  %
  % :param roiFilename: path to roi image.
  % :type  roiFilename: path
  %
  % :return: :roiBidsFile: (bids.File object)
  %
  %

  % (C) Copyright 2022 bidspm developers

  deformationField = bids.File(deformationField);

  roiFilename = bids.File(roiFilename);

  % fix entity key name for normalized image filename if it exists
  % and initialize entity keys that do not exist
  fields = {'hemi', 'seg', 'label'};

  for iField = 1:numel(fields)

    this_field = [spm_get_defaults('normalise.write.prefix') fields{iField}];

    if isfield(roiFilename.entities, this_field)

      roiFilename.entities = renameStructField(roiFilename.entities, ...
                                               this_field, ...
                                               fields{iField});
    end

    if ~isfield(roiFilename.entities, fields{iField})
      roiFilename.entities.(fields{iField}) = '';
    end

  end

  % set session entity for deformation field
  if ~isfield(deformationField.entities, 'ses')
    deformationField.entities.ses = '';
  end

  nameStructure = struct('entities', struct('sub', deformationField.entities.sub, ...
                                            'ses', deformationField.entities.ses, ...
                                            'hemi', roiFilename.entities.hemi, ...
                                            'space', 'individual', ...
                                            'seg', roiFilename.entities.seg, ...
                                            'label', roiFilename.entities.label), ...
                         'suffix', 'mask', ...
                         'ext', '.nii');

  roiBidsFile = bids.File(nameStructure);
  roiBidsFile = roiBidsFile.reorder_entities();

end

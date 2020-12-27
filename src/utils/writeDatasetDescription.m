% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function writeDatasetDescription(opt)

  oldDatasetDescription = spm_jsonread(fullfile(opt.derivativesDir, 'dataset_description.json'));

  newDatasetDescription = datasetDescriptionDefaults();

  if isfield(oldDatasetDescription, 'DatasetDOI')
    newDatasetDescription.SourceDatasets{1}.DOI = ...
        oldDatasetDescription.DatasetDOI;
  end

  spm_jsonwrite( ...
                fullfile(opt.derivativesDir, 'dataset_description.json'), ...
                newDatasetDescription, ...
                struct('indent', '   '));

end

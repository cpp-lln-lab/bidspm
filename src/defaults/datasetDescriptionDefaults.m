function datasetDescription = datasetDescriptionDefaults()
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  datasetDescription.Name = 'cpp_spm outputs';
  datasetDescription.BIDSVersion = '1.4.1';
  datasetDescription.DatasetType = 'derivative';

  datasetDescription.GeneratedBy = {struct( ...
                                           'Name', 'cpp_spm', ...
                                           'Version', getVersion(), ...
                                           'Container', struct('Type', '', 'Tag', ''))};

  % RECOMMENDED
  datasetDescription.License = '';
  datasetDescription.Authors = {''};
  datasetDescription.Acknowledgements = '';
  datasetDescription.HowToAcknowledge = '';
  datasetDescription.Funding = {''};
  datasetDescription.ReferencesAndLinks = {''};
  datasetDescription.DatasetDOI = '';
  datasetDescription.SourceDatasets = {struct('DOI', '', 'URL', '', 'Version', '')};

  % sort fields alphabetically
  datasetDescription = orderfields(datasetDescription);

end

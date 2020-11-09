% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function optSource = checkOptionsSource(optSource)
  %
  % Check the option inputs for source data and add any missing field with some defaults
  %
  % USAGE::
  %
  %   optSource = checkOptionsSource(optSource)
  %
  % :param optSource: Obligatory argument. The structure that contains the options set by the user
  %                   to run the batch workflow for source processing
  %
  % :returns: - :optSource: (struc) The structure with any unset fields with the deaufalt values

  fieldsToSet = setDefaultOptionSource();

  optSource = setDefaultFields(optSource, fieldsToSet);

  if isempty(optSource.sourceDir) || ~isdir(optSource.sourceDir)

    error('The source folder does not exist, try again.');

  end

  if isempty(optSource.sequenceToIgnore)

    warning('No sequence to ignore provided, I will convert all the images that I can found');

  end

end

function fieldsToSet = setDefaultOptionSource()
  % This defines the missing fields

  % The directory where the source data are located
  fieldsToSet.sourceDir = '';

  % The list of sequence(s) to ignore
  fieldsToSet.sequenceToIgnore = {};

  % Data format conversion (0 is reccomended)
  fieldsToSet.dataType = 0;

  % Boolean to enable gzip of the new 4D file
  fieldsToSet.zip = 0;

  % Number of volumes to discard ad dummies
  fieldsToSet.nbDummies = 0;

  % The list of sequence(s) where to discarding the dummies
  fieldsToSet.sequenceRmDummies = {};

end

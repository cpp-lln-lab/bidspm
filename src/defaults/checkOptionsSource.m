% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function optSource = checkOptionsSource(optSource)
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
  % .. todo:
  %
  %    - item 1
  %    - item 2

  fieldsToSet = setDefaultOptionSource();

  optSource = setDefaultFields(optSource, fieldsToSet);

  if isempty(optSource.sourceDir) || ~isdir(optSource.sourceDir)

    error('The source folder does not exist, try again.');

  end

  if isempty(optSource.sequenceToIgnore)

    warning('No sequence to ingore provided, I will convert all the images that I can found');

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

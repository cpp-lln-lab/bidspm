function expectedOptions = defaultOptions(taskName)
  %

  % (C) Copyright 2021 bidspm developers

  expectedOptions.verbosity = 2;
  expectedOptions.tolerant = true;
  expectedOptions.dryRun = false;

  expectedOptions.bidsFilterFile = struct('fmap', struct('modality', 'fmap'), ...
                                          'bold', struct('modality', 'func', 'suffix', 'bold'), ...
                                          't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
                                          't1w',  struct('modality', 'anat', ...
                                                         'space', '', ...
                                                         'suffix', 'T1w'), ...
                                          'mp2rage',  struct('modality', 'anat', ...
                                                             'space', '', ...
                                                             'suffix', 'MP2RAGE'), ...
                                          'roi',  struct('modality', 'roi', 'suffix', 'mask'), ...
                                          'xfm',  struct('modality', 'anat', ...
                                                         'suffix', 'xfm', ...
                                                         'to', 'T1w'));

  expectedOptions.pipeline.type =  '';
  expectedOptions.pipeline.isBms =  false;
  expectedOptions.pipeline.name = 'bidspm';

  expectedOptions.boilerplate_only = false;

  expectedOptions.anatOnly = false;

  expectedOptions.space = {'individual', 'IXI549Space'};

  expectedOptions.useBidsSchema = false;

  expectedOptions.fwhm.func = 6;
  expectedOptions.fwhm.contrast = 0;

  expectedOptions.dummy_scans = 0;

  expectedOptions.stc.referenceSlice = [];
  expectedOptions.stc.skip = false;

  expectedOptions.dir = struct('input', '', ...
                               'output', '', ...
                               'derivatives', '', ...
                               'raw', '', ...
                               'preproc', '', ...
                               'stats', '', ...
                               'jobs', '');

  expectedOptions.funcVoxelDims = [];

  expectedOptions.funcVolToSelect = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.query.modality = {'anat', 'func'};

  expectedOptions.segment.do = true;
  expectedOptions.segment.force = false;
  expectedOptions.segment.biasfwhm = 60;
  expectedOptions.segment.samplingDistance = 3;

  expectedOptions.skullstrip.do = true;
  expectedOptions.skullstrip.force = false;
  expectedOptions.skullstrip.threshold = 0.75;
  expectedOptions.skullstrip.mean = false;

  expectedOptions.realign.useUnwarp = true;
  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = {''};

  expectedOptions.zeropad = 2;

  expectedOptions.rename.do = true;
  expectedOptions.rename.overwrite = true;

  expectedOptions.QA.glm.do = false;

  expectedOptions.glm.roibased.do = false;
  expectedOptions.glm.maxNbVols = Inf;
  expectedOptions.glm.useDummyRegressor = false;
  expectedOptions.glm.keepResiduals = false;

  expectedOptions.model.file = '';
  expectedOptions.model.designOnly = false;
  expectedOptions.contrastList = {};

  expectedOptions.results = defaultResultsStructure();

  if nargin > 0
    expectedOptions.taskName = taskName;
  end
  if ~iscell(expectedOptions.taskName)
    expectedOptions.taskName = {expectedOptions.taskName};
  end

  expectedOptions = setFields(expectedOptions, MACS_my_defaults());

  expectedOptions.msg.color = '';

  expectedOptions = orderfields(expectedOptions);

  expectedOptions = setDirectories(expectedOptions);

end

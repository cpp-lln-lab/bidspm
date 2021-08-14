function expectedOptions = defaultOptions(taskName)
  %
  % (C) Copyright 2021 CPP_SPM developers

  expectedOptions.stc.sliceOrder = [];
  expectedOptions.stc.referenceSlice = [];
  expectedOptions.stc.skip = false;

  expectedOptions.dataDir = '';
  expectedOptions.derivativesDir = '';
  expectedOptions.dir = struct('raw', '', ...
                               'derivatives', '');

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.query = struct([]);

  expectedOptions.space = 'MNI';

  expectedOptions.anatReference.type = 'T1w';
  expectedOptions.anatReference.session = [];

  expectedOptions.skullstrip.threshold = 0.75;
  expectedOptions.skullstrip.mean = false;

  expectedOptions.realign.useUnwarp = true;
  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = '';

  expectedOptions.zeropad = 2;

  expectedOptions.contrastList = {};

  expectedOptions.glm.QA.do = true;
  expectedOptions.glm.roibased.do = false;

  expectedOptions.model.file = '';
  expectedOptions.model.hrfDerivatives = [0 0];

  expectedOptions.result.Steps = returnDefaultResultsStructure();

  expectedOptions.parallelize.do = false;
  expectedOptions.parallelize.nbWorkers = 3;
  expectedOptions.parallelize.killOnExit = false;

  if nargin > 0
    expectedOptions.taskName = taskName;
  end

  %  Options for toolboxes
  global ALI_TOOLBOX_PRESENT

  checkToolbox('ALI');
  if ALI_TOOLBOX_PRESENT
    expectedOptions = setFields(expectedOptions, ALI_my_defaults());
  end

  expectedOptions = orderfields(expectedOptions);

  expectedOptions = setStatsDir(expectedOptions);

end

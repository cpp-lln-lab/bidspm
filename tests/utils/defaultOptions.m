function expectedOptions = defaultOptions(taskName)
  %
  % (C) Copyright 2021 CPP_SPM developers

  expectedOptions.pipeline.type =  'preproc';
  expectedOptions.pipeline.name = 'cpp_spm';

  expectedOptions.sliceOrder = [];
  expectedOptions.STC_referenceSlice = [];

  expectedOptions.dir = struct('input', '', ...
                               'output', '', ...
                               'derivatives', '', ...
                               'raw', '', ...
                               'preproc', '', ...
                               'stats', '');

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.query.modality = {'anat', 'func', 'dwi'};

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

  expectedOptions = setFields(expectedOptions, rsHRF_my_defaults());

  expectedOptions = orderfields(expectedOptions);

  expectedOptions = setDirectories(expectedOptions);

end

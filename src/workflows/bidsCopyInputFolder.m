function derivatives = bidsCopyInputFolder(opt, pipeline_name, unzip)
  %
  % Copies the folders from the ``raw`` folder to the
  % ``derivatives`` folder, and will copy the dataset description and task json files
  % to the derivatives directory.
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files for the task of interest.
  %
  % USAGE::
  %
  %   bidsCopyRawFolder([opt,] ...
  %                     [deleteZippedNii = true,] ...
  %                     [modalitiesToCopy = {'anat', 'func', 'fmap'}])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param modalitiesToCopy: for example ``{'anat', 'func', 'fmap'}``
  % :type modalitiesToCopy: cell
  % :param unZip:
  % :type unZip: boolean
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 1 || isempty(opt)
    opt = [];
  end

  if nargin < 2 || isempty(pipeline_name)
    pipeline_name = 'cpp_spm';
  end

  if nargin < 2 || isempty(unzip)
    unzip = true();
  end

  opt = loadAndCheckOptions(opt);

  cleanCrash();

  printWorklowName('copy data');

  %% All tasks in this experiment
  % raw directory and derivatives directory
  opt = setDerivativesDir(opt, pipeline_name);

  createDerivativeDir(opt);

  if isempty(opt.dir.input)
    opt.dir.input = opt.dir.raw;
  end

  copyTsvJson(opt.dir.input, opt.dir.derivatives);

  %% Loop through the groups, subjects, sessions
  if any(ismember(opt.query.modality, 'func'))
    [BIDS, opt] = getData(opt, opt.dir.input);
  else
    [BIDS, opt] = getData(opt, opt.dir.input, 'T1w');
  end

  use_schema = true;
  overwrite = true;
  skip_dependencies = false;
  verbose = true;

  for iModality = 1:numel(opt.query.modality)

    filter = opt.query;
    filter.modality = opt.query.modality{iModality};

    if strcmp(filter.modality, 'func')
      filter.task = opt.taskName;
    end

    derivatives = bids.copy_to_derivative(BIDS, ...
                                          fullfile(opt.dir.derivatives, '..'), ...
                                          pipeline_name, ...
                                          filter, ...
                                          unzip, ...
                                          overwrite, ...
                                          skip_dependencies, ...
                                          use_schema, ...
                                          verbose);
  end

end

function copyTsvJson(srcDir, targetDir)
  % copy TSV and JSON file from raw folder

  ext = {'tsv', 'json'};

  for i = 1:numel(ext)

    if ~isempty(spm_select('List', srcDir, ['^.*.' ext{i} '$']))

      copyfile(fullfile(srcDir, ['*.' ext{i}]), targetDir);
      fprintf(1, ' %s files copied\n', ext{i});

    end

  end

end

function opt = setDerivativesDir(opt, pipeline_name)
  %
  % Sets the derivatives folder and the directory where to save the SPM jobs.
  % The actual creation of the directory is done by
  % ``createDerivativeDir(opt)``.
  %
  % USAGE::
  %
  %   opt = setDerivativesDir(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns:
  %   - :opt: structure or json filename containing the options. See
  %           ``checkOptions()`` and ``loadAndCheckOptions()``.
  %
  % Examples::
  %
  %   opt.dataDir = '/home/remi/data';
  %   opt.taskName = 'testTask';
  %   opt = setDerivativesDir(opt);
  %
  %   disp(opt.dir.derivatives)
  %   '/home/remi/data/../derivatives/cpp_spm'
  %
  %   disp(opt.odr.jobs)
  %   '/home/remi/data/../derivatives/cpp_spm/JOBS/testTask
  %
  %   opt.dataDir = '/home/remi/data';
  %   opt.dataDir = '/home/remi/otherFolder';
  %   opt.taskName = 'testTask';
  %   opt = setDerivativesDir(opt);
  %
  %   disp(opt.dir.derivatives)
  %   '/home/remi/otherFolder/derivatives/cpp_spm'
  %
  %   opt.dataDir = '/home/remi/data';
  %   opt.dataDir = '/home/remi/derivatives/preprocessing';
  %   opt.taskName = 'testTask';
  %   opt = setDerivativesDir(opt);
  %
  %   disp(opt.dir.derivatives)
  %   '/home/remi/otherFolder/derivatives/preprocessing'
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 2
    pipeline_name = 'cpp_spm';
  end

  if ~isfield(opt.dir, 'derivatives') || isempty(opt.dir.derivatives)
    opt.dir.derivatives = fullfile(opt.dir.input, '..', 'derivatives', pipeline_name);
  end

  try
    folders = split(opt.dir.derivatives, filesep);
  catch
    % for octave
    folders = strsplit(opt.dir.derivatives, filesep);
  end

  if strcmp(folders{end}, 'derivatives')
    folders{end + 1} = pipeline_name;
  end

  if ~strcmp(folders{end - 1}, 'derivatives') && ~strcmp(folders{end}, pipeline_name)
    folders{end + 1} = 'derivatives';
    folders{end + 1} = pipeline_name;
  end

  try
    tmp = join(folders, filesep);
    opt.dir.derivatives = tmp{1};

  catch
    % for octave
    opt.dir.derivatives = strjoin(folders, filesep);
  end

  opt.dir.derivatives = spm_file(opt.dir.derivatives, 'cpath');

  % Suffix output directory for the saved jobs
  opt.dir.jobs = fullfile(opt.dir.derivatives, 'jobs');
  if isfield(opt, 'taskName')
    opt.dir.jobs = fullfile(opt.dir.derivatives, 'jobs', opt.taskName);
  end

  % for backward compatibility
  opt.derivativesDir = opt.dir.derivatives;
  opt.jobsDir = opt.dir.jobs;

end

% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = setDerivativesDir(opt)
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
  % :returns: :opt: structure or json filename containing the options. See
  %           ``checkOptions()`` and ``loadAndCheckOptions()``.
  %
  % Examples:
  %   % opt.dataDir = '/home/remi/data';
  %   % opt.taskName = 'testTask';
  %   % opt = setDerivativesDir(opt);
  %   %
  %   % disp(opt.derivativesDir)
  %   %|| '/home/remi/data/../derivatives/cpp_spm'
  %   %
  %   % disp(opt.opt.jobsDir)
  %   %|| '/home/remi/data/../derivatives/cpp_spm/JOBS/testTask
  %
  %   % opt.dataDir = '/home/remi/data';
  %   % opt.dataDir = '/home/remi/otherFolder';
  %   % opt.taskName = 'testTask';
  %   % opt = setDerivativesDir(opt);
  %   %
  %   % disp(opt.derivativesDir)
  %   %|| '/home/remi/otherFolder/derivatives/cpp_spm'
  %
  %   % opt.dataDir = '/home/remi/data';
  %   % opt.dataDir = '/home/remi/derivatives/preprocessing';
  %   % opt.taskName = 'testTask';
  %   % opt = setDerivativesDir(opt);
  %   %
  %   % disp(opt.derivativesDir)
  %   %|| '/home/remi/otherFolder/derivatives/preprocessing'
  %
  %

  if ~isfield(opt, 'derivativesDir') || isempty(opt.derivativesDir)
    opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm');

  end

  try
    folders = split(opt.derivativesDir, filesep);
  catch
    % for octave
    folders = strsplit(opt.derivativesDir, filesep);
  end

  if strcmp(folders{end}, 'derivatives')
    folders{end + 1} = 'cpp_spm';
  end

  if ~strcmp(folders{end - 1}, 'derivatives') && ~strcmp(folders{end}, 'cpp_spm')
    folders{end + 1} = 'derivatives';
    folders{end + 1} = 'cpp_spm';
  end

  try
    tmp = join(folders, filesep);
    opt.derivativesDir = tmp{1};
  catch
    % for octave
    opt.derivativesDir = strjoin(folders, filesep);
  end

  % Suffix output directory for the saved jobs
  opt.jobsDir = fullfile(opt.derivativesDir, 'JOBS', opt.taskName);

end

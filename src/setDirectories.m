function opt = setDirectories(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isempty(opt.dir.input)
    opt.dir.input = opt.dir.raw;
  end

  if ~isempty(opt.dir.input)
    opt.dir.derivatives = fullfile(opt.dir.input, '..');
  end

  if ~isempty(opt.dir.preproc)
    opt.dir.derivatives = spm_fileparts(opt.dir.preproc);
  end

  opt.dir.derivatives = setDerivativesDir(opt.dir.derivatives);

  switch opt.pipeline.type
    case 'preproc'
      opt.dir.preproc = fullfile(opt.dir.derivatives, opt.pipeline.name);
      opt.dir.jobs = setJobsDir(opt, opt.dir.preproc);
    case 'stats'
      opt.dir.stats = fullfile(opt.dir.derivatives, opt.pipeline.name);
      opt.dir.jobs = setJobsDir(opt, opt.dir.stats);
  end

end

function derDir = setDerivativesDir(derDir)

  [~, tmp] = spm_fileparts(derDir);

  if ~strcmp(tmp, 'derivatives')
    derDir =  fullfile(derDir, 'derivatives');
  end

  derDir = spm_file(derDir, 'cpath');

end

function jobDir = setJobsDir(opt, targetDir)

  jobDir = fullfile(targetDir, 'jobs');
  if isfield(opt, 'taskName')
    jobDir = fullfile(targetDir, 'jobs', opt.taskName);
  end

end

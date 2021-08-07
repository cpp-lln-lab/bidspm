function opt = setDirectories(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isempty(opt.dir.input)
    opt.dir.input = opt.dir.raw;
  end

  if ~isempty(opt.dir.input)

    if ~isempty(opt.dir.output)
      opt.dir.jobs = setJobsDir(opt, opt.dir.output);
      return
    end

    opt.dir.derivatives = spm_file(fullfile(opt.dir.input, '..'), 'cpath');
  end

  if ~isempty(opt.dir.preproc)
    opt.dir.derivatives = spm_fileparts(opt.dir.preproc);
  end

  opt.dir.derivatives = setDerivativesDir(opt.dir.derivatives);

  if endsWith(opt.dir.(opt.pipeline.type), opt.pipeline.type) || ...
      endsWith(opt.pipeline.name, opt.pipeline.type)
  elseif ~strcmp(opt.pipeline.name, opt.pipeline.type)
    tmp = fullfile(opt.dir.derivatives, [opt.pipeline.name '-' opt.pipeline.type]);
    opt.dir.(opt.pipeline.type) = tmp;
  end

  if isempty(opt.dir.(opt.pipeline.type))
    opt.dir.(opt.pipeline.type) = fullfile(opt.dir.derivatives, opt.pipeline.name);
  end

  opt.dir.jobs = setJobsDir(opt, opt.dir.(opt.pipeline.type));

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

function opt = setDirectories(opt)
  %
  % USAGE::
  %
  %   opt = setDirectories(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~isempty(opt.dir.input) && ~isempty(opt.dir.output)
    opt = setJobsDir(opt, opt.dir.output);
    return
  end

  opt = setDerivativesDir(opt);
  opt = setDir(opt, 'preproc');
  opt = setDir(opt, 'stats');
  opt = setInputDir(opt);
  opt = setOutputDir(opt);
  opt = setJobsDir(opt, opt.dir.output);

  fields = fieldnames(opt.dir);
  for i = 1:numel(fields)
    opt.dir.(fields{i}) = canonicalizeIfNonEmpty(opt.dir.(fields{i}));
  end

end

function opt = setInputDir(opt)

  inputDir = opt.dir.input;

  if isempty(inputDir)
    if ~isempty(opt.dir.raw) && ismember(opt.pipeline.type, {'preproc', ''})
      inputDir = fullfile(opt.dir.raw);
    elseif ~isempty(opt.dir.preproc)
      inputDir = fullfile(opt.dir.preproc);
    end
  end
  
  opt.dir.input = inputDir;

end

function opt = setDerivativesDir(opt)

  derDir = opt.dir.derivatives;

  if isempty(derDir)

    if ~isempty(opt.dir.preproc)
      derDir = fullfile(opt.dir.preproc, '..');
    elseif ~isempty(opt.dir.stats)
      derDir = fullfile(opt.dir.stats, '..');
    elseif ~isempty(opt.dir.raw)
      derDir = fullfile(opt.dir.raw, '..', 'derivatives');
    elseif ~isempty(opt.dir.input)
      derDir = fullfile(opt.dir.input, '..', 'derivatives');
    end

  end

  derDir = canonicalizeIfNonEmpty(derDir);

  % derivatives dir must have "derivatives" as final folder
  [~, tmp] = spm_fileparts(derDir);
  if ~strcmp(tmp, 'derivatives')
    derDir =  fullfile(derDir, 'derivatives');
  end

  opt.dir.derivatives = derDir;

end

function opt = setDir(opt, step)
  %
  % to set preproc and stats directory
  %

  if ~strcmp(opt.pipeline.type, step)
    return

  else
    
    % check that the pth ends with the pipeline type (preproc or stats) or
    % is just derivatives
    if ~isempty(opt.dir.(step)) && ( ...
                                    ~strcmp(spm_file(opt.dir.(step), 'basename'), ...
                                            'derivatives') || ...
                                    ~bids.internal.ends_with(opt.dir.(step), opt.pipeline.type))
      opt.dir.(step) = '';
    end
    
    if isempty(opt.dir.(step))
      % try to avoid creating folders called "preproc-preproc"
      if strcmp(opt.pipeline.name, opt.pipeline.type)
        folder_name = opt.pipeline.name;
      else
        folder_name = [opt.pipeline.name '-' opt.pipeline.type];
      end
      opt.dir.(step) = fullfile(opt.dir.derivatives, folder_name);
      return

    end
    
  end

end

function opt = setOutputDir(opt)

  outputDir = opt.dir.output;

  if isempty(outputDir)
    switch opt.pipeline.type
      case {'preproc', 'stats'}
        outputDir = opt.dir.(opt.pipeline.type);
      otherwise
        outputDir = opt.dir.preproc;
    end
  end
  
  opt.dir.output = outputDir;

end

function opt = setJobsDir(opt, targetDir)

  jobDir = fullfile(targetDir, 'jobs');
  
  if isfield(opt, 'taskName') && ~isempty(opt.taskName) && ~isempty(opt.taskName{1})
    jobDir = fullfile(targetDir, 'jobs',  strjoin(opt.taskName, ''));
  end
  
  opt.dir.jobs = jobDir;

end

function pth = canonicalizeIfNonEmpty(pth)
  if ~isempty(pth)
    pth = spm_file(pth, 'cpath');
  end
end

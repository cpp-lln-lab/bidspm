function opt = setStatsDir(opt)
  %
  % USAGE::
  %
  %  opt = setStatsDir(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt = setDerivativesDir(opt);

  if ~isfield(opt.dir, 'stats')
    opt.dir.stats = fullfile(opt.dir.derivatives, '..', 'cpp_spm-stats');
  end

  opt.dir.stats = spm_file(opt.dir.stats, 'cpath');

end

% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function opt = setStatsDir(opt)

  opt = setDerivativesDir(opt);

  if ~isfield(opt.dir, 'stats')
    opt.dir.stats = fullfile(opt.derivativesDir, '..', 'cpp_spm-stats');
  end

end

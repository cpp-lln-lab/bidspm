function matlabbatch = setBatchGoodnessOfFit(matlabbatch, opt)

  % (C) Copyright 2023 bidspm developers

  if bids.internal.is_octave()
    % https://github.com/cpp-lln-lab/bidspm/pull/1135#issuecomment-1722455363
    notImplemented(mfilename(), ...
                   'Goodness of fit not implemented in Octave.', ...
                   opt);
    return
  end

  MA_inspect_GoF.SPM_mat(1) = cfg_dep('Model estimation: SPM.mat File', ...
                                      returnDependency(opt, 'estimate'), ...
                                      substruct('.', 'spmmat'));
  MA_inspect_GoF.plot_type = 1;

  matlabbatch{end + 1}.spm.tools.MACS.MA_inspect_GoF = MA_inspect_GoF;

end

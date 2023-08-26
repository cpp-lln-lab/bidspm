function matlabbatch = setBatchGoodnessOfFit(matlabbatch, opt)

  % (C) Copyright 2023 bidspm developers

  MA_inspect_GoF.SPM_mat(1) = cfg_dep('Model estimation: SPM.mat File', ...
                                      returnDependency(opt, 'estimate'), ...
                                      substruct('.', 'spmmat'));
  MA_inspect_GoF.plot_type = 1;

  matlabbatch{end + 1}.spm.tools.MACS.MA_inspect_GoF = MA_inspect_GoF;

end

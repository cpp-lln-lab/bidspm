function matlabbatch = setBatchInformationCriteria(matlabbatch, opt, outputDir)

  % (C) Copyright 2023 bidspm developers
  MA_model_space.dir = {outputDir};
  MA_model_space.models{1}{1}(1) = cfg_dep('Model estimation: SPM.mat File', ...
                                           returnDependency(opt, 'estimate'), ...
                                           substruct('.', 'spmmat'));
  MA_model_space.names = {'GLM'};

  matlabbatch{end + 1}.spm.tools.MACS.MA_model_space = MA_model_space;

  MA_classic_ICs_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', ...
                                          substruct('.', 'val', '{}', {numel(matlabbatch)}, ...
                                                    '.', 'val', '{}', {1}, ...
                                                    '.', 'val', '{}', {1}, ...
                                                    '.', 'val', '{}', {1}), ...
                                          substruct('.', 'MS_mat'));
  MA_classic_ICs_auto.ICs.AIC = 1;
  MA_classic_ICs_auto.ICs.AICc = 0;
  MA_classic_ICs_auto.ICs.BIC = 1;
  MA_classic_ICs_auto.ICs.DIC = 0;
  MA_classic_ICs_auto.ICs.HQC = 0;
  MA_classic_ICs_auto.ICs.KIC = 0;
  MA_classic_ICs_auto.ICs.KICc = 0;

  matlabbatch{end + 1}.spm.tools.MACS.MA_classic_ICs_auto = MA_classic_ICs_auto;

end

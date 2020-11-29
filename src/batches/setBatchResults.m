% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results)
  %
  % Outputs the typical matlabbatch to compute the results for a given contrast
  %
  % USAGE::
  %
  %   matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param iStep:
  % :type iStep: positive integer
  % :param iCon:
  % :type iCon: positive integer
  % :param results:
  % :type results: structure
  %
  %   results.dir = ffxDir;
  %   results.contrastNb = conNb;
  %   results.label = subID;
  %   results.nbSubj = 1;
  %
  % :returns: - :matlabbatch: (structure)
  %
  %

  matlabbatch{end + 1}.spm.stats.results.spmmat = {fullfile(results.dir, 'SPM.mat')};

  matlabbatch{end}.spm.stats.results.conspec.titlestr = ...
      opt.result.Steps(iStep).Contrasts(iCon).Name;

  matlabbatch{end}.spm.stats.results.conspec.contrasts = results.contrastNb;

  matlabbatch{end}.spm.stats.results.conspec.threshdesc = ...
      opt.result.Steps(iStep).Contrasts(iCon).MC;

  matlabbatch{end}.spm.stats.results.conspec.thresh = opt.result.Steps(iStep).Contrasts(iCon).p;

  matlabbatch{end}.spm.stats.results.conspec.extent = opt.result.Steps(iStep).Contrasts(iCon).k;

  matlabbatch{end}.spm.stats.results.conspec.conjunction = 1;

  matlabbatch{end}.spm.stats.results.conspec.mask.none = ...
      ~opt.result.Steps(iStep).Contrasts(iCon).Mask;

  matlabbatch{end}.spm.stats.results.units = 1;

  % TODO
  % add flags to make those optional
  matlabbatch{end}.spm.stats.results.export{1}.png = true;
  matlabbatch{end}.spm.stats.results.export{2}.csv = true;
  matlabbatch{end}.spm.stats.results.export{3}.tspm.basename = ...
      opt.result.Steps(iStep).Contrasts(iCon).Name;

  % TODO
  % add the possibility to create a montage
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.background = '<UNDEFINED>';
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.orientation = '<UNDEFINED>';
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.slices = '<UNDEFINED>';

  if opt.result.Steps(1).Contrasts(iCon).NIDM

    matlabbatch{end}.spm.stats.results.export{end + 1}.nidm.modality = 'FMRI';

    matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'ixi';
    if strcmp(opt.space, 'T1w')
      matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'subject';
    end

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.nsubj = results.nbSubj;

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.label = results.label;

  end

end

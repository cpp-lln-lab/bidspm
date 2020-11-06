% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function batch = setBatchResults(batch, opt, iStep, iCon, results)
  % outputs the typical matlabbatch to compute the results for a given
  % contrast

  batch{end + 1}.spm.stats.results.spmmat = {fullfile(results.dir, 'SPM.mat')};

  batch{end}.spm.stats.results.conspec.titlestr = ...
      opt.result.Steps(iStep).Contrasts(iCon).Name;

  batch{end}.spm.stats.results.conspec.contrasts = results.contrastNb;

  batch{end}.spm.stats.results.conspec.threshdesc = ...
      opt.result.Steps(iStep).Contrasts(iCon).MC;

  batch{end}.spm.stats.results.conspec.thresh = opt.result.Steps(iStep).Contrasts(iCon).p;

  batch{end}.spm.stats.results.conspec.extent = opt.result.Steps(iStep).Contrasts(iCon).k;

  batch{end}.spm.stats.results.conspec.conjunction = 1;

  batch{end}.spm.stats.results.conspec.mask.none = ...
      ~opt.result.Steps(iStep).Contrasts(iCon).Mask;

  batch{end}.spm.stats.results.units = 1;

  batch{end}.spm.stats.results.export{1}.ps = true;

  if opt.result.Steps(1).Contrasts(iCon).NIDM

    batch{end}.spm.stats.results.export{2}.nidm.modality = 'FMRI';

    batch{end}.spm.stats.results.export{2}.nidm.refspace = 'ixi';
    if strcmp(opt.space, 'T1w')
      batch{end}.spm.stats.results.export{2}.nidm.refspace = 'subject';
    end

    batch{end}.spm.stats.results.export{2}.nidm.group.nsubj = results.nbSubj;

    batch{end}.spm.stats.results.export{2}.nidm.group.label = results.label;

  end

end

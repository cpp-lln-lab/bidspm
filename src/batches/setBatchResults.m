% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function batch = setBatchResults(batch, opt, iStep, iCon, results)
   %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
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

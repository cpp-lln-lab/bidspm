function matlabbatch = setBatchResults(matlabbatch, opt, result)
  %
  % Outputs the typical matlabbatch to compute the result for a given contrast
  %
  % Common for all type of results: run, session, subject, dataset
  %
  % USAGE::
  %
  %   matlabbatch = setBatchResults(matlabbatch, opt, result)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param results:
  % :type results: structure
  %
  %   results.dir = ffxDir;
  %   results.contrastNb = conNb;
  %   results.label = subLabel;
  %   results.nbSubj = 1;
  %
  % :return: :matlabbatch: (structure)
  %
  % See also: setBatchSubjectLevelResults, setBatchGroupLevelResults
  %
  %

  % (C) Copyright 2019 bidspm developers

  result.outputName = returnResultNameSpec(opt, result);

  stats.results.spmmat = {fullfile(result.dir, 'SPM.mat')};

  stats.results.conspec.titlestr = returnName(result);

  stats.results.conspec.contrasts = result.contrastNb;
  stats.results.conspec.threshdesc = result.MC;
  stats.results.conspec.thresh = result.p;
  stats.results.conspec.extent = result.k;
  stats.results.conspec.conjunction = 1;
  stats.results.conspec.mask.none = ~result.useMask;

  stats.results.units = 1;

  matlabbatch{end + 1}.spm.stats = stats;

  %% set up how to export the results
  export = [];

  %%
  if result.png
    export{end + 1}.png = true;
  end

  %%
  if result.csv
    export{end + 1}.csv = true;
  end

  %%
  if result.threshSpm
    result.outputName.ext = '';
    result.outputName.suffix = 'spmT';
    bidsFile = bids.File(result.outputName);
    export{end + 1}.tspm.basename = bidsFile.filename;
  end

  %%
  if result.binary
    result.outputName.ext = '';
    result.outputName.suffix = 'mask';
    bidsFile = bids.File(result.outputName);
    export{end + 1}.binary.basename = bidsFile.filename;
  end

  export = setNidm(export, result);

  %%
  if result.montage.do
    export{end + 1}.montage = setMontage(result);
  end

  matlabbatch{end}.spm.stats.results.export = export;

  if result.montage.do

    % Not sure why the name of the figure does not come out right
    result.outputName.ext = '';
    result.outputName.suffix = 'montage';
    bidsFile = bids.File(result.outputName);
    matlabbatch{end + 1}.spm.util.print.fname = bidsFile.filename;
    matlabbatch{end}.spm.util.print.fig.figname = 'SliceOverlay';
    matlabbatch{end}.spm.util.print.opts = 'png';

  end

end

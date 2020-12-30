% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchResults(matlabbatch, result)
  %
  % Outputs the typical matlabbatch to compute the results for a given contrast
  %
  % USAGE::
  %
  %   matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
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
  
  fieldsToSet = returnDefaultResultsStructureBasic();
  result = setDefaultFields(result, fieldsToSet);

  matlabbatch{end + 1}.spm.stats.results.spmmat = {fullfile(result.dir, 'SPM.mat')};

  matlabbatch{end}.spm.stats.results.conspec.titlestr = result.Contrasts.Name;

  matlabbatch{end}.spm.stats.results.conspec.contrasts = result.contrastNb;
  matlabbatch{end}.spm.stats.results.conspec.threshdesc = result.Contrasts.MC;
  matlabbatch{end}.spm.stats.results.conspec.thresh = result.Contrasts.p;
  matlabbatch{end}.spm.stats.results.conspec.extent = result.Contrasts.k;
  matlabbatch{end}.spm.stats.results.conspec.conjunction = 1;
  matlabbatch{end}.spm.stats.results.conspec.mask.none = ~result.Contrasts.useMask;

  matlabbatch{end}.spm.stats.results.units = 1;

  matlabbatch{end}.spm.stats.results.export = [];
  if result.Output.png
    matlabbatch{end}.spm.stats.results.export{end+1}.png = true;
  end
  
  if result.Output.csv
    matlabbatch{end}.spm.stats.results.export{end+1}.csv = true;
  end
  
  if result.Output.thresh_spm
    matlabbatch{end}.spm.stats.results.export{end+1}.tspm.basename = result.Contrasts.Name;
  end

  % TODO
  % add the possibility to create a montage
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.background = '<UNDEFINED>';
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.orientation = '<UNDEFINED>';
  %   matlabbatch{1}.spm.stats.results.export{3}.montage.slices = '<UNDEFINED>';

  if result.Output.NIDM_results

    matlabbatch{end}.spm.stats.results.export{end + 1}.nidm.modality = 'FMRI';

    matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'ixi';
    if strcmp(result.space, 'individual')
      matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'subject';
    end

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.nsubj = result.nbSubj;

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.label = result.label;

  end

end

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

  fieldsToSet = returnDefaultResultsStructure();
  result = setDefaultFields(result, fieldsToSet);
  result.Contrasts = replaceEmptyFields(result.Contrasts, fieldsToSet.Contrasts);

  matlabbatch{end + 1}.spm.stats.results.spmmat = {fullfile(result.dir, 'SPM.mat')};

  matlabbatch{end}.spm.stats.results.conspec.titlestr = returnName(result);

  matlabbatch{end}.spm.stats.results.conspec.contrasts = result.contrastNb;
  matlabbatch{end}.spm.stats.results.conspec.threshdesc = result.Contrasts.MC;
  matlabbatch{end}.spm.stats.results.conspec.thresh = result.Contrasts.p;
  matlabbatch{end}.spm.stats.results.conspec.extent = result.Contrasts.k;
  matlabbatch{end}.spm.stats.results.conspec.conjunction = 1;
  matlabbatch{end}.spm.stats.results.conspec.mask.none = ~result.Contrasts.useMask;

  matlabbatch{end}.spm.stats.results.units = 1;

  matlabbatch{end}.spm.stats.results.export = [];
  if result.Output.png
    matlabbatch{end}.spm.stats.results.export{end + 1}.png = true;
  end

  if result.Output.csv
    matlabbatch{end}.spm.stats.results.export{end + 1}.csv = true;
  end

  if result.Output.thresh_spm
    matlabbatch{end}.spm.stats.results.export{end + 1}.tspm.basename = returnName(result);
  end

  if result.Output.binary
    matlabbatch{end}.spm.stats.results.export{end + 1}.binary.basename = [returnName(result), ...
                                                                          '_mask'];
  end

  if result.Output.NIDM_results

    matlabbatch{end}.spm.stats.results.export{end + 1}.nidm.modality = 'FMRI';

    matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'ixi';
    if strcmp(result.space, 'individual')
      matlabbatch{end}.spm.stats.results.export{end}.nidm.refspace = 'subject';
    end

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.nsubj = result.nbSubj;

    matlabbatch{end}.spm.stats.results.export{end}.nidm.group.label = result.label;

  end

  if result.Output.montage.do

    matlabbatch{end}.spm.stats.results.export{end + 1}.montage = setMontage(result);

    % Not sure why the name of the figure does not come out right
    matlabbatch{end + 1}.spm.util.print.fname = ['Montage_' returnName(result)];
    matlabbatch{end}.spm.util.print.fig.figname = 'SliceOverlay';
    matlabbatch{end}.spm.util.print.opts = 'png';

  end

end

function struct = replaceEmptyFields(struct, fieldsToCheck)

  fieldsList = fieldnames(fieldsToCheck);

  for  iField = 1:numel(fieldsList)
    if isfield(struct, fieldsList{iField}) && isempty(struct.(fieldsList{iField}))
      struct.(fieldsList{iField}) = fieldsToCheck.(fieldsList{iField});
    end
  end

end

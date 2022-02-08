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
  % (C) Copyright 2019 CPP_SPM developers

  result.outputNameStructure.use_schema = false;
  result.outputNameStructure.entities.sub = result.label;
  result.outputNameStructure.entities.desc = result.Contrasts.Name;
  result.outputNameStructure.entities.p = num2str(result.Contrasts.p);
  result.outputNameStructure.entities.k = num2str(result.Contrasts.k);
  result.outputNameStructure.entities.MC = result.Contrasts.MC;

  fieldsToSet = returnDefaultResultsStructure();
  result = setFields(result, fieldsToSet);
  result.Contrasts = replaceEmptyFields(result.Contrasts, fieldsToSet.Contrasts);

  stats.results.spmmat = {fullfile(result.dir, 'SPM.mat')};

  stats.results.conspec.titlestr = returnName(result);

  stats.results.conspec.contrasts = result.contrastNb;
  stats.results.conspec.threshdesc = result.Contrasts.MC;
  stats.results.conspec.thresh = result.Contrasts.p;
  stats.results.conspec.extent = result.Contrasts.k;
  stats.results.conspec.conjunction = 1;
  stats.results.conspec.mask.none = ~result.Contrasts.useMask;

  stats.results.units = 1;

  matlabbatch{end + 1}.spm.stats = stats;

  %% set up how to export the results
  export = [];
  if result.Output.png
    export{end + 1}.png = true;
  end

  if result.Output.csv
    export{end + 1}.csv = true;
  end

  if result.Output.thresh_spm
    result.outputNameStructure.ext = '';
    export{end + 1}.tspm.basename = bids.create_filename(result.outputNameStructure);
  end

  if result.Output.binary
    result.outputNameStructure.ext = '';
    result.outputNameStructure.suffix = 'mask';
    export{end + 1}.binary.basename = bids.create_filename(result.outputNameStructure);
  end

  if result.Output.NIDM_results

    nidm.modality = 'FMRI';

    nidm.refspace = 'ixi';
    if strcmp(result.space, 'individual')
      nidm.refspace = 'subject';
    end

    nidm.group.nsubj = result.nbSubj;

    nidm.group.label = result.label;

    export{end + 1}.nidm = nidm;

  end

  matlabbatch{end}.spm.stats.results.export = export;

  if result.Output.montage.do

    matlabbatch{end}.spm.stats.results.export{end + 1}.montage = setMontage(result);

    % Not sure why the name of the figure does not come out right
    result.outputNameStructure.ext = '';
    result.outputNameStructure.suffix = 'montage';
    matlabbatch{end + 1}.spm.util.print.fname = bids.create_filename(result.outputNameStructure);
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

function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, nodeName)
  %
  % set batch for run and subject level contrasts
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type subLabel: char
  %
  % :return: matlabbatch
  %
  %
  % See also: bidsFFX, specifyContrasts, setBatchContrasts
  %
  %

  % (C) Copyright 2019 bidspm developers

  printBatchName('subject level contrasts specification', opt);

  spmMatFile = fullfile(getFFXdir(subLabel, opt), 'SPM.mat');
  if ~checkSpmMat(dir, opt)
    return
  end

  load(spmMatFile, 'SPM');

  bm = opt.model.bm;
  bm.validateConstrasts();

  % Create Contrasts
  if nargin < 4 || isempty(nodeName)
    contrasts = specifyContrasts(bm, SPM);
  else
    contrasts = specifyContrasts(bm, SPM, nodeName);
  end

  validateContrasts(contrasts);

  consess = {};
  for icon = 1:numel(contrasts)

    if any(contrasts(icon).C(:))

      con.name = contrasts(icon).name;
      con.convec = contrasts(icon).C;
      con.sessrep = 'none';

      switch contrasts(icon).type
        case 't'
          consess{end + 1}.tcon = con; %#ok<*AGROW>

        case 'F'
          consess{end + 1}.fcon = con; %#ok<*AGROW>
      end

    end

  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end

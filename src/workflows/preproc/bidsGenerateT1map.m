function matlabbatch = bidsGenerateT1map(opt)
  %
  % Brief workflow description
  %
  % USAGE::
  %
  %  bidsGenerateT1map(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %

  % (C) Copyright 2022 bidspm developers

  [BIDS, opt] = setUpWorkflow(opt, 'generate T1maps');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchGenerateT1map(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'generate T1 map', opt, subLabel);

    opt.query.suffix = 'UNIT1';

    % extract into a renaming config function
    opt.spm_2_bids = Mapping;

    prefix = matlabbatch{1}.spm.tools.mp2rage.estimateT1.outputT1.prefix;
    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', prefix, ...
                                                'suffix', 'UNIT1', ...
                                                'name_spec', struct('prefix', '', ...
                                                                    'suffix', 'T1map'));

    prefix = matlabbatch{1}.spm.tools.mp2rage.estimateT1.outputR1.prefix;
    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', prefix, ...
                                                'suffix', 'UNIT1', ...
                                                'name_spec', struct('prefix', '', ...
                                                                    'suffix', 'R1map'));

    opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();

    bidsRename(opt);

  end

  cleanUpWorkflow(opt);

end

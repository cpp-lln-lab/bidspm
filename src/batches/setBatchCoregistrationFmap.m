function matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel)
  %
  % Set the batch for the coregistration of field maps
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel)
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % TODO
  % - implement for 'phase12', 'fieldmap', 'epi'
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('coregister fieldmaps data to functional', opt);

  % Use a rough mean of the 1rst run to improve SNR for coregistration
  % created by spmup
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  filter = struct( ...
                  'sub', subLabel, ...
                  'task', opt.taskName, ...
                  'suffix', 'bold', ...
                  'prefix', 'mean_');
  refImage = bids.query(BIDS, 'data', filter);

  for iSes = 1:nbSessions

    filter = opt.query;
    filter.modality =  'fmap';
    filter.sub =  subLabel;
    filter.ses =  sessions{iSes};

    runs = bids.query(BIDS, 'runs', filter);

    for iRun = 1:numel(runs)

      filter.run = runs{iRun};
      filter.suffix = 'phasediff';
      filter.extension = '.nii';

      metadata = bids.query(BIDS, 'metadata', filter);

      if strfind(metadata.IntendedFor, opt.taskName)

        otherImages = cell(2, 1);
        otherImages(2) = bids.query(BIDS, 'data', filter);
        filter.suffix = 'magnitude2';
        otherImages(1) = bids.query(BIDS, 'data', filter);

        filter.suffix = 'magnitude1';
        srcImage = bids.query(BIDS, 'data', filter);

        matlabbatch = setBatchCoregistration(matlabbatch, opt, refImage, srcImage{1}, otherImages);

      end

    end

  end

end

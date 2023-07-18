function matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel)
  %
  % Set the batch for the coregistration of field maps
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel)
  %
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % TODO implement for 'phase12', 'fieldmap', 'epi'
  %

  % (C) Copyright 2020 bidspm developers

  printBatchName('coregister fieldmaps data to functional', opt);

  % Use a rough mean of the 1rst run to improve SNR for coregistration
  % created by spmup
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');
  filter = struct('sub', subLabel, ...
                  'task', opt.taskName, ...
                  'suffix', 'bold', ...
                  'ses',  sessions{1}, ...
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

      if numel(metadata) > 1
        error('Only one file expected');
      end

      if any(strfind(metadata.IntendedFor, opt.taskName))

        otherImages = cell(2, 1);
        otherImages(2) = bids.query(BIDS, 'data', filter);
        filter.suffix = 'magnitude2';
        otherImages(1) = bids.query(BIDS, 'data', filter);

        filter.suffix = 'magnitude1';
        srcImage = bids.query(BIDS, 'data', filter);

        matlabbatch = setBatchCoregistration(matlabbatch, opt, ...
                                             refImage{1}, ...
                                             srcImage{1}, ...
                                             otherImages);

      end

    end

  end

end

function matlabbatch = setBatchGenerateT1map(varargin)
  %
  % batch to create a T1 and R1 map from MP2RAGE
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGenerateT1map(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  %
  % :param BIDS: BIDS layout returned by ``getData`` or ``bids.layout`.
  % :type BIDS: structure
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param subLabel: subject label
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  % Relies on the MP2RAGE toolbox for SPM.
  %
  %   https://github.com/benoitberanger/mp2rage
  %
  % Some non-BIDS metadata need to be added to the JSON files of the inversion
  % images for this to work (check the README of the toolbox for more info):
  %
  %   - ``EchoSpacing``
  %   - ``PartialFourierInSlice``: between 0 and 1 (example: 6/8)
  %   - ``FatSat``: must be "yes" or "no"
  %
  % Most of the those metadata should be available from the PDF of with yout
  % sequence details.
  %
  % (C) Copyright 2022 CPP_SPM developers

  defaultT1Prefix = 'qT1';
  defaultR1Prefix = 'qR1';

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'BIDS', @isstruct);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  BIDS = args.Results.BIDS;
  opt = args.Results.opt;
  subLabel = args.Results.subLabel;

  filter = opt.bidsFilterFile.mp2rage;
  filter.sub = subLabel;

  printBatchName('generate T1 map', opt);

  sessions = bids.query(BIDS, 'sessions', filter);

  nbSessions = numel(sessions);
  if nbSessions == 0
    nbSessions = 1;
    sessions = {''};
  end

  for iSes = 1:nbSessions

    filter.ses = sessions{iSes};

    runs = bids.query(BIDS, 'runs', filter);

    nbRuns = numel(runs);

    if isempty(runs)
      nbRuns = 1;
      runs = {''};
    end

    for iRun = 1:nbRuns

      filter.run = runs{iRun};

      filter.suffix = 'UNIT1';
      uniT1 = bids.query(BIDS, 'data', filter);

      if numel(uniT1) < 1
        msg = sprintf('No UNIT1 image found for %s', createUnorderedList(filter));
        id = 'missingUniT1';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);
        continue
      end

      if numel(uniT1) > 1
        msg = sprintf('Too many UNIT1 image found for %s', createUnorderedList(filter));
        id = 'tooManyUniT1';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);
        continue
      end

      filter.suffix = 'MP2RAGE';
      filter.inv = '1';
      metadataInv1 = bids.query(BIDS, 'metadata', filter);

      filter.suffix = 'MP2RAGE';
      filter.inv = '2';
      metadataInv2 = bids.query(BIDS, 'metadata', filter);

      if numel(metadataInv1) < 1 || numel(metadataInv2) < 1
        msg = sprintf('Missing metadata for INV images for %s', createUnorderedList(filter));
        id = 'missingMetadata';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);
        continue
      end

      estimateT1.UNI = uniT1;

      estimateT1.B0 = metadataInv1.MagneticFieldStrength;

      estimateT1.TR = metadataInv1.RepetitionTimePreparation;

      estimateT1.TI = [metadataInv1.InversionTime, metadataInv2.InversionTime];

      estimateT1.FA = [metadataInv1.FlipAngle metadataInv2.FlipAngle];

      estimateT1.outputT1.prefix = defaultT1Prefix;
      estimateT1.outputR1.prefix = defaultR1Prefix;

      try
        hdr = spm_vol(uniT1);
      catch
        % for testing only
        hdr{1}.dim(1) = nan;
      end
      estimateT1.nrSlices = hdr{1}.dim(1);

      % Things that are not officially part of BIDS
      % but that should be added to the JSON of the inversion images
      try
        estimateT1.EchoSpacing = metadataInv1.EchoSpacing;
        estimateT1.PartialFourierInSlice = metadataInv1.PartialFourierInSlice;
        estimateT1.FatSat = metadataInv1.FatSat;
      catch
        msg = sprintf('Missing non-BIDS metadata for %s\nSee ''help setBatchGenerateT1map''', ...
                      createUnorderedList(filter));
        id = 'missingNonBIDSMetadata';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);
        continue
      end

      matlabbatch{end + 1}.spm.tools.mp2rage.estimateT1 = estimateT1;

    end

  end

end

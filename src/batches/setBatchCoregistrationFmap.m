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

  printBatchName('coregister fieldmaps data to functional');

  % Use a rough mean of the 1rst run to improve SNR for coregistration
  % created by spmup
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, sessions{1}, runs{1}, opt);
  refImage = validationInputFile(subFuncDataDir, fileName, 'mean_');

  for iSes = 1:nbSessions

    runs = bids.query(BIDS, 'runs', ...
                      'modality', 'fmap', ...
                      'sub', subLabel, ...
                      'ses', sessions{iSes});

    for iRun = 1:numel(runs)

      metadata = bids.query(BIDS, 'metadata', ...
                            'modality', 'fmap', ...
                            'sub', subLabel, ...
                            'ses', sessions{iSes}, ...
                            'run', runs{iRun});

      if strfind(metadata.IntendedFor, opt.taskName)

        fmapFiles = bids.query(BIDS, 'data', ...
                               'modality', 'fmap', ...
                               'sub', subLabel, ...
                               'ses', sessions{iSes}, ...
                               'run', runs{iRun});

        srcImage = strrep(fmapFiles{1}, 'phasediff', 'magnitude1');

        otherImages = cell(2, 1);
        otherImages{1} = strrep(fmapFiles{1}, 'phasediff', 'magnitude2');
        otherImages{2} = fmapFiles{1};

        matlabbatch = setBatchCoregistration(matlabbatch, refImage, srcImage, otherImages);

      end

    end

  end

end

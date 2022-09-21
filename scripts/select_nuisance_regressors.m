% (C) Copyright 2022 bidspm developers

% Takes the .tsv file with the nuisance regressors and adds a "included_"
% prefix to the regressors that are chosen. Regressors are chosen to
% explain most variance.

% maxNbRegPerTissue defines the number of regressors per tissu (here CSF) is chosen.
% The N maxNbRegPerTissue will be picked.

clear;
clc;

data_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', 'MoAE', 'inputs', 'fmriprep');
tasks = {'auditory'};

opt.columnsToInclude = {'c_comp_cor'};
opt.tissueNames = {'CSF'};
opt.maxNbRegPerTissue = 2;
opt.prefix = 'included_';

BIDS = bids.layout(data_dir, 'use_schema', false, 'verbose', true);
subjects = bids.query(BIDS, 'subjects');

for iSub = 1:numel(subjects)

  for iTask = 1:numel(tasks)

    tsvFiles = bids.query(BIDS, 'data', ...
                          'sub', subjects{iSub}, ...
                          'task', tasks{iTask}, ...
                          'suffix', {'timeseries', 'regressors'}, ...
                          'ext', '.tsv');

    metadataTsv = bids.query(BIDS, 'metadata', ...
                             'sub', subjects{iSub}, ...
                             'task', tasks{iTask}, ...
                             'suffix', {'timeseries', 'regressors'}, ...
                             'ext', '.tsv');

    for iRun = 1:numel(tsvFiles)

      tsvContent = bids.util.tsvread(tsvFiles{iRun});
      if numel(tsvFiles) == 1
        metadata = metadataTsv;
      else
        metadata = metadataTsv{iRun};
      end

      newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata, opt);

      bids.util.tsvwrite(tsvFiles{iRun}, newTsvContent);

    end

  end

end

function bidsQA(opt, varargin)
  %
  % Run QA on a BIDS dataset.
  %

  % (C) Copyright 2024 Remi Gau

  dsDesc = bids.util.jsondecode(fullfile(opt.dir.input, 'dataset_description.json'));

  switch dsDesc.DatasetType

    case 'raw'

      [BIDS, opt] = setUpWorkflow(opt, 'QA', opt.dir.input);

      bids.diagnostic(BIDS, ...
                      'split_by', {'task'}, ...
                      'output_path', fullfile(opt.dir.output, 'reports'), ...
                      'verbose', false);

    case 'derivative'

      pipelines = {};
      for i = 1:numel(dsDesc.GeneratedBy)
        pipelines {end+1} = dsDesc.GeneratedBy(i).Name; %#ok<*AGROW>
      end

      if ismember('MRIQC', pipelines)
        opt.dir.mriqc = opt.dir.input;
        bidsQAmriqc(opt, 'T1w');
        bidsQAmriqc(opt, 'bold');

      elseif  any(ismember({'fMRIPrep', 'bidspm'}, pipelines))
        bidsQApreproc(opt, varargin{:});
      end
  end
end

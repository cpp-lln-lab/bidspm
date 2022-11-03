function validate(args)
  %
  % Validate bids dataset and bids stats model
  %
  %

  % (C) Copyright 2022 bidspm developers
  if args.Results.skip_validation
    return
  end

  % run validation if validators are installed locally

  printToScreen(sprintf('\nValidating bids dataset:\n %s\n', args.Results.bids_dir));

  [sts_data, msg_data] = bids.validate(args.Results.bids_dir);
  if sts_data == 1 && ~startsWith(msg_data, 'Require')
    msg_data = sprintf('\nBIDS validation of %s failed:\n\n%s\n\nCheck with\n: %s\n\n', ...
                       args.Results.bids_dir, ...
                       msg_data, ...
                       'https://bids-standard.github.io/bids-validator/');
    errorHandling(mfilename(), 'invalidBidsDataset', msg_data, false);
  elseif args.Results.verbosity > 0
    disp(msg_data);
  end

  if ismember(args.Results.action, {'stats', 'contrasts', 'results'})
    cmd = sprintf('validate_model %s', ...
                  args.Results.model_file);
    [sts_model, msg_model] = system(cmd);

    if args.Results.verbosity > 0
      disp(msg_model);
    end
    if sts_model ~= 0
      msg_model = sprintf(['\nBIDS stats models could not be validated.', ...
                           '\nTo silence this warning install bsmschema:', ...
                           '\n   pip install bsmschema']);
      errorHandling(mfilename(), 'invalidModel', msg_model, true, args.Results.verbosity);
    end
  end

end

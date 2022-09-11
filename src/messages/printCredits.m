function printCredits(opt)
  %
  % TODO use the .CFF to load contributors
  %
  % (C) Copyright 2019 bidspm developers

  if nargin < 1
    opt.verbosity = 2;
  end

  versionNumber = getVersion();

  try

    content = bids.util.jsondecode(fullfile(returnRootDir(), '.all-contributorsrc'));
    contributors = {content.contributors.name}';
    contributors = contributors(randperm(numel(contributors)));
    contributors = cat(1, contributors, 'Why not be the next?');

  catch

    contributors = {'Mohamed Rezk', ...
                    'Remi Gau', ...
                    'Olivier Collignon', ...
                    'Ane Gurtubay', ...
                    'Marco Barilari', ...
                    'Iqra Shahzad', ...
                    'Filippo Cerpelloni', ...
                    'Michele MacLean', ...
                    'Iqra Shahzad', ...
                    'Filippo Cerpelloni', ...
                    'Federica Falagiarda ', ...
                    'Ceren Battal', ...
                    'Marcia Nunes', ...
                    'Why not be the next?'};
  end

  DOI_URL = 'https://doi.org/10.5281/zenodo.3554331.';
  horLine = '____________________________________________________________\n';

  printToScreen(horLine, opt);
  printToScreen(horLine, opt);
  printToScreen('\n', opt);

  printToScreen('______  _____ ______  _____ ______ ___  ___    \n', opt,  'format', '*green');
  printToScreen('| ___ \\|_   _||  _  \\/  ___|| ___ \\|  \\/  |\n', opt,  'format', '*green');
  printToScreen('| |_/ /  | |  | | | |\\ `--. | |_/ /| .  . |   \n', opt,  'format', '*green');
  printToScreen('| ___ \\  | |  | | | | `--. \\|  __/ | |\\/| | \n', opt,  'format', '*green');
  printToScreen('| |_/ / _| |_ | |/ / /\\__/ /| |    | |  | |   \n', opt,  'format', '*green');
  printToScreen('\\____/  \\___/ |___/  \\____/ \\_|    \\_|  |_/\n', opt,  'format', '*green');

  printToScreen('\n', opt);

  printToScreen('\n\n', opt);
  printToScreen('Thank you for using bidspm - ', opt);
  printToScreen(sprintf('version %s ', versionNumber), opt, 'format', '-blue');
  printToScreen('\n\n', opt);

  printToScreen('Current list of contributors includes\n');
  printToScreen(createUnorderedList(contributors), opt);

  printToScreen(sprintf('\n\n'), opt);

  printToScreen('Please cite using the following DOI: \n ', opt);
  printToScreen(sprintf('%s', DOI_URL), opt, 'format', 'hyper');
  printToScreen(sprintf('\n\n'), opt);

  printToScreen('For bug report & suggestions see our github repo: \n ', opt);
  printToScreen(sprintf('%s', returnRepoURL()), opt, 'format', 'hyper');
  printToScreen(sprintf('\n\n'), opt);

  printToScreen(horLine, opt);
  printToScreen(horLine, opt);

  printToScreen('\n\n', opt);

end

function printCredits(opt)
  %
  % TODO use the .CFF to load contributors
  %
  % (C) Copyright 2019 CPP_SPM developers

  versionNumber = getVersion();

  contributors = { ...
                  'Mohamed Rezk', ...
                  'Remi Gau', ...
                  'Olivier Collignon', ...
                  'Ane Gurtubay', ...
                  'Marco Barilari', ...
                  'Michele MacLean', ...
                  'Iqra Shahzad', ...
                  'Filippo Cerpelloni', ...
                  'Federica Falagiarda ', ...
                  'Ceren Battal'};

  DOI_URL = 'https://doi.org/10.5281/zenodo.3554331.';

  if opt.verbosity > 1

    disp('___________________________________________________________________________');
    disp('___________________________________________________________________________');
    disp('                                                   ');
    disp('                 __  ____  ____     _      _    _  ');
    disp('                / _)(  _ \(  _ \   | |    / \  | ) ');
    disp('               ( (_  )___/ )___/   | |_  / _ \ | \ ');
    disp('                \__)(__)  (__)     |___||_/ \_||__)');
    disp('                                                   ');

    splash = 'Thank you for using CPP SPM - version %s. ';
    fprintf(splash, versionNumber);
    fprintf('\n\n');

    fprintf('Current list of contributors includes\n');
    for iCont = 1:numel(contributors)
      fprintf(' %s\n', contributors{iCont});
    end
    fprintf('\b\n\n');

    fprintf('Please cite using the following DOI: \n %s\n\n', DOI_URL);

    fprintf('For bug report & suggestions see our github repo: \n %s\n\n', returnRepoURL());

    disp('___________________________________________________________________________');
    disp('___________________________________________________________________________');

    fprintf('\n\n');

  end

end

% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function printCredits()

  versionNumber = getVersion();

  % TODO: use the .zenodo.json to load contributors
  contributors = { ...
                  'Mohamed Rezk', ...
                  'Remi Gau', ...
                  'Olivier Collignon', ...
                  'Ane Gurtubay', ...
                  'Marco Barilari', ...
                  'Michele MacLean', ...
                  'Federica Falagiarda ', ...
                  'Ceren Battal'};

  DOI_URL = 'https://doi.org/10.5281/zenodo.3554331.';

  repoURL = 'https://github.com/cpp-lln-lab/CPP_SPM';

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

  fprintf('For bug report & suggestions see our github repo: \n %s\n\n', repoURL);

  disp('___________________________________________________________________________');
  disp('___________________________________________________________________________');

  fprintf('\n\n');

end

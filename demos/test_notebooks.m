function status = test_notebooks()
  % run all the scripts derived from notebooks

  % (C) Copyright 2021 Remi Gau

  status = true;

  this_dir = fileparts(mfilename('fullpath'));

  folders = dir(this_dir);

  failed = {};

  for idir = 1:numel(folders)

    if ~folders(idir).isdir
      continue
    end

    notebooks = dir(fullfile(this_dir, folders(idir).name));

    for nb = 1:numel(notebooks)

      if regexp(notebooks(nb).name, '^.*.ipynb$')

        fprintf(1, '\n');
        disp(notebooks(nb).name);
        fprintf(1, '\n');

        [~, name] = fileparts(notebooks(nb).name);
        matlab_script = fullfile(this_dir, folders(idir).name, [name, '.m']);

        try
          run(matlab_script);
        catch
          status = false;
          failed{end + 1} = matlab_script; %#ok<AGROW>

        end
      end

    end

    for f = 1:numel(failed)
      warning('\n\tRunning %s failed.\n', failed{f});
    end

  end

end

function manageWorkersPool(action, opt)
  %
  % Check matlab version and opens pool of workers for parallel work.
  %
  % USAGE::
  %
  %   manageWorkersPool(action, opt)
  %
  % :param action: ``'open'`` or ``'close'``
  % :type action: string
  % :param opt:
  % :type opt: structure
  %
  % Requires to set some options::
  %
  %    opt.parallelize.do = true;
  %    opt.parallelize.nbWorkers = 3;
  %    opt.parallelize.killOnExit = true;
  %
  % (C) Copyright 2020 CPP_SPM developers

  if isOctave() || ~license('test', 'Distrib_Computing_Toolbox')
    return
  end

  if ~opt.parallelize.do
    opt.parallelize.nbWorkers = 1;
    opt.parallelize.killOnExit = false;
  end

  matlabVer = version('-release');

  nbWorkers = opt.parallelize.nbWorkers;

  switch lower(action)

    case 'open'

      if str2double(matlabVer(1:4)) > 2013

        pool = gcp('nocreate');

        if isempty(pool)
          parpool(nbWorkers); %#ok<*DPOOL>
        end

      else

        if matlabpool('size') == 0 %#ok<*DPOOL>
          matlabpool(nbWorkers);

        elseif matlabpool('size') ~= nbWorkers
          matlabpool close;
          matlabpool(nbWorkers);

        end

      end

    case 'close'

      if opt.parallelize.killOnExit

        if str2double(matlabVer(1:4)) > 2013

          pool = gcp('nocreate');
          if ~isempty(pool)
            delete(gcp);
          end

        else
          matlabpool close;

        end

      end

  end

end

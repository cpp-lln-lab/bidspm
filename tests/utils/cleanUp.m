function cleanUp(folder)
  %
  % (C) Copyright 2021 CPP_SPM developers

  pause(0.1);

  if is_octave()
    confirm_recursive_rmdir (true, 'local');
  end
  try
    rmdir(folder, 's');
  catch
  end

  delete('*.png');
  delete('*.json');

end

function image = removeSpmPrefix(image, prefix)
  %
  % (C) Copyright 2019 CPP_SPM developers

  basename = spm_file(image, 'basename');
  tmp = spm_file(image, 'basename', basename(length(prefix) + 1:end));
  movefile(image, tmp);
  image = tmp;

end

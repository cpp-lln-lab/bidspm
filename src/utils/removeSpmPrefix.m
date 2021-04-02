% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function image = removeSpmPrefix(image, prefix)

  basename = spm_file(image, 'basename');
  tmp = spm_file(image, 'basename', basename(length(prefix) + 1:end));
  movefile(image, tmp);
  image = tmp;

end

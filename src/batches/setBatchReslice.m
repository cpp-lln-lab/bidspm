% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % matlabbatch = bidsSmoothing(referenceImg, sourceImages)
  %
  % referenceImg
  %
  % sourceImages: a cell

  printBatchName('reslicing');

  if ischar(referenceImg)
    matlabbatch{end + 1}.spm.spatial.coreg.write.ref = {referenceImg};

  elseif isstruct(referenceImg)
  end

  if iscell(sourceImages)
    matlabbatch{1}.spm.spatial.coreg.write.source = sourceImages;

  elseif isstruct(sourceImages)
  end

end

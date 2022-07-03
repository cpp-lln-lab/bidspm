function acquisitionTime = getAcquisitionTime(sliceOrder, repetitionTime)
  %
  %
  % USAGE::
  %
  %   acquisitionTime = getAcquisitionTime(sliceOrder)
  %
  % :param metadata: sliceOrder
  % :type  metadata: vector
  %
  % :returns: - :acquisitionTime:
  %
  % (C) Copyright 2022 CPP_SPM developers

  % SPM accepts slice time acquisition as inputs for slice order
  % (simplifies things when dealing with multiecho data)

  sliceOrder = unique(sliceOrder);

  acquisitionTime = repetitionTime - repetitionTime / numel(sliceOrder);

  assert(~any(sliceOrder > acquisitionTime));

end

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

  % (C) Copyright 2022 bidspm developers

  % SPM accepts slice time acquisition as inputs for slice order
  % (simplifies things when dealing with multiecho data)

  sliceOrder = unique(sliceOrder);

  acquisitionTime = repetitionTime - (repetitionTime / numel(sliceOrder));

  % ceil to avoid making this too brittle
  if any(sliceOrder >= ceil(acquisitionTime * 1000) / 1000)
    msg = sprintf(['Acquisition time cannot be < to any slice timing value:\n\n', ...
                   'Current values:', ...
                   '\n- acquisition time: %f', ...
                   '\n- slice timing: ' pattern], ...
                  acquisitionTime, ...
                  sliceOrder);
    id = 'sliceTimingSuperiorToAcqTime';
    errorHandling(mfilename(), id, msg, false);
  end

end

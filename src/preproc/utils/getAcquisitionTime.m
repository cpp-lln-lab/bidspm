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

  acquisitionTime = computeAcquisitionTime(sliceOrder, repetitionTime);

  % ceil to avoid making this too brittle
  if any(sliceOrder >= ceil(acquisitionTime * 1000) / 1000)
    sliceOrder = bids.internal.create_unordered_list(num2str(sliceOrder));
    msg = sprintf(['Acquisition time cannot be < to any slice timing value:\n\n', ...
                   'Current values:', ...
                   '\n- acquisition time: %f', ...
                   '\n- slice timing %s'], ...
                  acquisitionTime, ...
                  sliceOrder);
    id = 'sliceTimingSuperiorToAcqTime';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

end

function acquisitionTime = computeAcquisitionTime(sliceOrder, repetitionTime)
  sliceOrder = unique(sliceOrder);
  acquisitionTime = repetitionTime - (repetitionTime / numel(sliceOrder));
end

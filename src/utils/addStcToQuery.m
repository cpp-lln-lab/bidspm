function opt = addStcToQuery(opt)
  %
  % (C) Copyright 2020 CPP_SPM developers
  if ~opt.stc.skip
    if (isfield(opt.metadata, 'SliceTiming') && ~isempty(opt.metadata.SliceTiming)) || ...
        ~isempty(opt.stc.sliceOrder)
      opt.query.desc = 'stc';
    end
  end
end

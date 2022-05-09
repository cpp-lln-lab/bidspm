function uninitCppSpm()
  %
  % Removes the added folders fromthe path for a given session.
  %
  % USAGE::
  %
  %   uninitCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  warning('DEPRECATED: use `cpp_spm(''uninit'')` instead');

  cpp_spm('uninit');

end

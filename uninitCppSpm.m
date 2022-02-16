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

  if dev
    cpp_spm('dev');
  else
    cpp_spm('uninit');
  end

end

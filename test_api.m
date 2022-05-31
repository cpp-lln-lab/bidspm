% test API
% (C) Copyright 2019 CPP_SPM developers

% initialise (add relevant folders to path)
cpp_spm;
cpp_spm('action', 'uninit');
cpp_spm('action', 'init');
cpp_spm('action', 'uninit');

% also adds folder for testing to the path
cpp_spm('action', 'dev');
cpp_spm('action', 'uninit');

% misc
cpp_spm('action', 'version');

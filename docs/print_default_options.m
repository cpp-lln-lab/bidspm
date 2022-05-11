% prints the default options to a file to be easily added to the doc

run ../cpp_spm;
opt = struct();
opt = checkOptions(opt);
file_id = fopen(fullfile(pwd, 'source', 'default_options.m'), 'w+');
unfold(opt, 'opt', true, file_id);
fclose(file_id);

system('make clean_default_options');

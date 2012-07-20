function output = functionNameExtractor(input_path)

m_extension_removal = strfind(input_path,'.m');

remaining_string = input_path(1:m_extension_removal-1);

forward_slash_finder = strfind(remaining_string,'\');

output = input_path(forward_slash_finder(end)+1:m_extension_removal-1);
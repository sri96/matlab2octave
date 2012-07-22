function output = pathExtractor(input_path)

%pathExtractor(input_path) is a reimplementation of functionNameExtractor
%function in which instead of returning the name of the function from path,
%this function just returns the remaining string after removing the
%function name and .m extension.

m_extension_removal = strfind(input_path,'.m');

remaining_string = input_path(1:m_extension_removal-1);

forward_slash_finder = strfind(remaining_string,'\');

output = input_path(1:forward_slash_finder(end)-1);
endfunction

function output = functionNameExtractor(input_path)

%functionNameExtractor(input_path) extracts the name of the .m file from
%the path.The process is straight forward. 

m_extension_removal = strfind(input_path,'.m');%finding the .m extension

remaining_string = input_path(1:m_extension_removal-1);%removing the .m 
%extension

forward_slash_finder = strfind(remaining_string,'\');%find all the forward
%slash in the remaining input path

output = input_path(forward_slash_finder(end)+1:m_extension_removal-1);
%Extract the string from the last forward slash to start of the m
%extension. The obtained string will be the name of the function. 
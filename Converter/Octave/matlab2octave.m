function matlab2octave(varargin)

%matlab2octave(varargin) function converts matlab code into compatible
%octave code. You can read detailed documentation with screen shots at
%https://github.com/adhithyan15/matlab2octave/wiki/Documentation.
%The function has been implemented in two versions using the builtin varargin
%command for user convenience.
%
%
%     Copyright (C) 2012  <Adhithya Rajasekaran>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

size_of_varargin = size(varargin);

if size_of_varargin(1,2) == 1
    %If the user is giving one input, then there are two possibilites. One
    %is it might be an .m file or it must be a folder full of .m files. So
    %we check for it here.

    input_path = varargin{1};

    is_m_file = strfind(input_path,'.m');%If an empty matrix is returned
    %from this call, we can definitely say that it is a folder full of .m
    %files. If it returns a number we can say that it is a single file
    %which needs to be converted.

    if isempty(is_m_file)

        fullFolderConverter(input_path);


    else

        singleFileConverter(input_path);


    endif

elseif size_of_varargin(1,2) == 2
    %If two inputs are given, then there are two possibilities. One is, the
    %user is giving us a .m file and also a corresponding folder to save
    %it.Or the user is giving us a folder full of .m files and also giving
    %us a corresponding folder to save all those .m files. We check for
    %both of them here.

    input_path = varargin{1};

    path_to_save_files = varargin{2};

    is_m_file = strfind(input_path,'.m');%If an empty matrix is returned
    %from this call, we can definitely say that it is a folder full of .m
    %files. If it returns a number we can say that it is a single file
    %which needs to be converted.

    %We call the corresponding function to solve the problem.

    if isempty(is_m_file)

        fullFolderConverter(input_path,path_to_save_files);



    else

        singleFileConverter(input_path,path_to_save_files);



    endif

endif



endfunction
function singleFileConverter(varargin)

size_of_varargin = size(varargin);%Size of the varargin is needed to direct
%the function to run either the one input version or the two input version.


if size_of_varargin(1,2) == 1%If there is only one input, then the function
    %does some extra work for the user.It creates new octave .m file and
    %names it appropriately to avoid overwriting.

    path_to_matlab_file = varargin{1};%The path to matlab file is extracted
    %from the varargin cell array.

    matlab_function_name = functionNameExtractor(path_to_matlab_file);%Matlab
    %function name is extracted from the path using the
    %functionNameExtractor function. Please read the documentation of
    %functionNameExtractor to learn how it is done.

    output_octave_file_name = [pathExtractor(path_to_matlab_file) '\' matlab_function_name 'Octave.m'];
    %Path to save the octave .m file is created.

    octave_file_handle = fopen(output_octave_file_name,'w');%The octave .m
    %file is created using the path created in the last step and is opened
    %for writing.


    %The following code block reads the matlab file line by line and
    %creates a cell array with each line of the matlab file as cell.This
    %code was inspired by a question in stackoverflow.

    matlab_file_as_array = readFileLineByLine(path_to_matlab_file);


    [modified_code_array,function_counter,location_of_functions_in_array] = codeModifier(matlab_file_as_array);

    modified_code_array = functionEnder(modified_code_array,location_of_functions_in_array,function_counter);

    modified_code_array = functionNameModifier(modified_code_array,matlab_function_name,location_of_functions_in_array);

    size_of_modified_code_array = size(modified_code_array);
    %Size of the modified compatible octave code is needed to set up the
    %looping constructs.

    for n = 1:size_of_modified_code_array

        fprintf(octave_file_handle,'%s\n',modified_code_array{n});

    endfor


    fclose(octave_file_handle);




elseif size_of_varargin(1,2) == 2

    path_to_matlab_file = varargin{1};

    path_to_save_octave_file = varargin{2};%This is provided by the user
    %and is not created for the user by matlab.

    if path_to_save_octave_file(end) == '\'

        path_to_save_octave_file = path_to_save_octave_file(1:end-1);

    endif

    if strcmpi(pathExtractor(path_to_matlab_file),path_to_save_octave_file) == 0



        if exist(path_to_save_octave_file,'dir') == 0

            mkdir(path_to_save_octave_file);

        endif

        matlab_function_name = functionNameExtractor(path_to_matlab_file);

        output_octave_file_name = [path_to_save_octave_file '\' matlab_function_name '.m'];

        octave_file_handle = fopen(output_octave_file_name,'w');

        matlab_file_as_array = readFileLineByLine(path_to_matlab_file);

        [modified_code_array,function_counter,location_of_functions_in_array] = codeModifier(matlab_file_as_array);

        modified_code_array = functionEnder(modified_code_array,location_of_functions_in_array,function_counter);

        size_of_modified_code_array = size(modified_code_array);
        %Size of the modified compatible octave code is needed to set up the
        %looping constructs.

        for n = 1:size_of_modified_code_array

            fprintf(octave_file_handle,'%s\n',modified_code_array{n});

        endfor


        fclose(octave_file_handle);

    else

        singleFileConverter(path_to_matlab_file);

    endif


endif

%fullFolderConverter function grabs the contents of the folder and finds
%all the .m files using the built in dir function. Then it runs through the
%loop sending each function to the singleFileConverter function with
%corresponding inputs.

endfunction
function fullFolderConverter(varargin)

size_of_varargin = size(varargin);

if size_of_varargin(1,2) == 1

    path_to_directory = varargin{1};

    if path_to_directory(end) == '\'

        path_to_directory = path_to_directory(1:end-1);

    endif

    directory_listing = dir(path_to_directory);

    size_of_directory_listing = size(directory_listing);

    for x = 3:size_of_directory_listing(1,1)

        current_file = directory_listing(x).name;

        is_m_file = strfind(current_file,'.m');

        if isempty(is_m_file) == 0

            path_to_file = [path_to_directory '\' current_file];

            singleFileConverter(path_to_file);

        endif


    endfor

elseif size_of_varargin(1,2) == 2


    path_to_directory = varargin{1};

    path_to_save_files_directory = varargin{2};

    if path_to_directory(end) == '\'

        path_to_directory = path_to_directory(1:end-1);

    endif

    if strcmpi(path_to_directory,path_to_save_files_directory) == 0

        if exist(path_to_save_files_directory,'dir') == 0

            mkdir(path_to_save_files_directory);

        endif

        directory_listing = dir(path_to_directory);

        size_of_directory_listing = size(directory_listing);

        for x = 3:size_of_directory_listing(1,1)

            current_file = directory_listing(x).name;

            is_m_file = strfind(current_file,'.m');

            if isempty(is_m_file) == 0

                path_to_file = [path_to_directory '\' current_file];

                singleFileConverter(path_to_file,path_to_save_files_directory);

            endif


        endfor

    else

        fullFolderConverter(path_to_directory);

    endif

endif



endfunction
function output = functionNameModifier(input_array,function_name,location_of_functions_in_array)

%functionNameModifier function changes the name of the octave main
%functions to prevent warnings from the octave interpreter because of name
%mismatch.

modified_function_name = [function_name 'Octave'];

main_function_in_array = input_array{location_of_functions_in_array(1,1),1};

replacement_of_name = strrep(main_function_in_array,function_name,modified_function_name);

input_array{location_of_functions_in_array(1,1),1} = replacement_of_name;


output = input_array;


endfunction
function output = functionEnder(input_array,location_of_functions,function_counter)

%functionEnder puts the 'endfunction' closure on all the functions in an .m
%file.

size_of_input_array = size(input_array);

location_of_functions = [location_of_functions;size_of_input_array(1,1)+1];

final_cell_array = {};

for x = 1:function_counter

    interim_cell_array = input_array(location_of_functions(x,1):location_of_functions(x+1,1)-1,:);

    interim_cell_array = [interim_cell_array; {'endfunction'}];

    final_cell_array = [final_cell_array; interim_cell_array];

endfor

output = final_cell_array;


endfunction
function output = readFileLineByLine(path_to_file)

%readFileLineByLine function reads any file and returns the contents of it
%as a cell array with each line of the function as cell.

file_id = fopen(path_to_file);

file_as_line_by_line_array = {};

individual_line = fgetl(file_id);

file_as_line_by_line_array = [file_as_line_by_line_array; {individual_line}];

while ischar(individual_line)

    individual_line = fgetl(file_id);
    file_as_line_by_line_array = [file_as_line_by_line_array;{individual_line}];

endwhile

fclose(file_id);

file_as_line_by_line_array(end) = [];

output = file_as_line_by_line_array;
endfunction

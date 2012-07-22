function matlab2octave(varargin)

%matlab2octave(varargin) function converts matlab code into compatible
%octave code. You can read detailed documentation with screen shots at
%https://github.com/adhithyan15/matlab2octave/wiki/Documentation.
%The function has been implemented in two versions using the builtin varargin
%command for user convenience.
%
%First version:
%
%   matlab2octave(path_to_matlab_file)
%
%   You just pass in the path of a matlab .m file. The function currently
%   supports both scripts and functions. Functions cannot have nested
%   functions in them because octave doesn't support nested functions as of
%   the latest release. If you sub functions with in a function, that would
%   be fine. The converter reads in the .m file as a txt file.It creates a
%   new octave .m file in the same directory with the same name as the passed in matlab .m file
%   and appends 'Octave' to the name to avoid over writing.
%
%       For Example: matlab2octave('C:\User\Joe\sampleMatlab.m') creates a
%       new octave .m file in the C:\User\Joe\ directory named
%       sampleMatlabOctave.m.
%
%   After creating the output octave file, it converts the matlab code to
%   compatible octave code and writes it to the created octave file.
%   Formatting is in no way disturbed. Comments are also left untouched.
%   This is the easiest way to convert matlab .m file to octave .m file.
%
%
%Second Version:
%
%   matlab2octave(path_to_matlab_file,path_to_save_octave_file)
%
%   You have to pass in the path of a matlab .m file and also the path to
%   save the octave .m file. The function currently
%   supports both scripts and functions. Functions cannot have nested
%   functions in them because octave doesn't support nested functions as of
%   the latest release. If you sub functions with in a function, that would
%   be fine. The function reads in the matlab .m file and creates an octave
%   .m file in the specified path with the same name as the passed in
%   matlab file.
%
%       For Example: matlab2octave('C:\User\Joe\sampleMatlab.m','C:\User\Joe\SomeFolder\') creates a
%       new octave .m file in the C:\User\Joe\SomeFolder\ directory named
%       sampleMatlab.m.
%
%   The converter assumes that path_to_matlab_file and path_to_save_octave_file
%   are different. If you provide the same directory for both the paths,
%   then it will result in overwriting of your matlab .m file. After creating
%   the output octave file, it converts the matlab code to
%   compatible octave code and writes it to the created octave file.
%   Formatting is in no way disturbed. Comments are also left untouched.
%
%
%
%This function and its dependencies are under consistent development.So you
%can grab the latest version of the package from https://github.com/adhithyan15/matlab2octave
%
%Please note that matlab browser is limited in its flexibility and functionality. So please
%copy paste the urls on your browser(Chrome,Mozilla,IE,Safari) to view the documentation and also to
%grab the latest version of the source code.
%
%The function needs the following .m files to run properly
%
%   codeModifier.m
%   functionNameExtractor.m
%   pathExtractor.m
%
%Please make sure that those files are in your path while running this
%function.
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
        
    end
    
    
    fclose(octave_file_handle);
    
   
    
    
elseif size_of_varargin(1,2) == 2
    
    path_to_matlab_file = varargin{1};
    
    path_to_save_octave_file = varargin{2};%This is provided by the user
    %and is not created for the user by matlab.
    
    if path_to_save_octave_file(end) == '\'
        
        path_to_save_octave_file = path_to_save_octave_file(1:end-1);
        
    end
    
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
        
    end
    
    
    fclose(octave_file_handle);
    
          
end


function output = functionNameModifier(input_array,function_name,location_of_functions_in_array)

%The following function is a reimplementation of the findAndLocateFunction
%function with slight changes. Instead of looking for all the functions it
%just looks for the first function because it is the main function.It
%changes the name of it by appending 'Octave' to the end of it to avoid
%warnings when executed in Octave.This function is applicable only to the
%first version of matlab2octave implementation.

modified_function_name = [function_name 'Octave'];

main_function_in_array = input_array{location_of_functions_in_array(1,1),1};

replacement_of_name = strrep(main_function_in_array,function_name,modified_function_name);

input_array{location_of_functions_in_array(1,1),1} = replacement_of_name;


output = input_array;


function output = functionEnder(input_array,location_of_functions,function_counter)

size_of_input_array = size(input_array);

location_of_functions = [location_of_functions;size_of_input_array(1,1)];

final_cell_array = {};

for x = 1:function_counter
    
    interim_cell_array = input_array(location_of_functions(x,1):location_of_functions(x+1,1)-1,:);
    
    interim_cell_array = [interim_cell_array; 'endfunction'];
    
    final_cell_array = [final_cell_array; interim_cell_array];
    
end

output = final_cell_array;


function output = readFileLineByLine(path_to_file)

file_id = fopen(path_to_file);

file_as_line_by_line_array = {};

individual_line = fgetl(file_id);

file_as_line_by_line_array = [file_as_line_by_line_array ; individual_line];

while ischar(individual_line)
    
    individual_line = fgetl(file_id);
    file_as_line_by_line_array = [file_as_line_by_line_array ;individual_line];
    
end

fclose(file_id);

file_as_line_by_line_array(end) = [];

output = file_as_line_by_line_array;






















































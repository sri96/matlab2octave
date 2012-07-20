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
    
    matlab_file_handle = fopen(path_to_matlab_file,'r');%The matlab file 
    %present in the given path is also opened in reading mode. 
    
    %The following code block reads the matlab file line by line and 
    %creates a cell array with each line of the matlab file as cell.This
    %code was inspired by a question in stackoverflow.
        
    matlab_file_as_array={};
    
    line_by_line_reading = fgetl(matlab_file_handle);
    
    while ischar(line_by_line_reading)
        
        matlab_file_as_array=[matlab_file_as_array;line_by_line_reading];
        
        line_by_line_reading = fgetl(matlab_file_handle);
        
    end
    
       
    modified_code_array = codeModifier(matlab_file_as_array);%CodeModifier 
    %converts matlab code into compatible octave code. Read the
    %documentation of code modifier to learn more about how it transforms
    %the code. 
    
    %The following operations are done to end matlab functions with
    %'endfunction' command to make them octave compatible.The following
    %steps are assuming that you ignored to put 'end' at the end of a
    %function. If you have already put 'end' at the end of your functions,
    %the following steps will mess your code. So please remove those 'end's
    %from your code. This issue is being worked on to be resolved. If you
    %have any comments, please visit https://github.com/adhithyan15/matlab2octave/issues
    %to tell me about that. 
    
    modified_code_array = functionNameModifier(modified_code_array,matlab_function_name);
    %This step is done to prevent octave from showing a function name
    %mismatch warning when the function is called. 
    
    [function_counter,location_of_functions_in_array] = findAndLocateFunction(modified_code_array);
    %FindAndLocateFunction identifies,counts and returns the exact location
    %of main function and its sub functions in an .m file. If there are no
    %functions in an .m file then 0 is returned. 
    
    size_of_modified_code_array = size(modified_code_array);
    %Size of the modified compatible octave code is needed to set up the
    %looping constructs. 
    
    if function_counter > 1%If more than one function is identified inside
        %a .m file, then the following body is executed. 
        
        function_index = 2;%The function_index is intialized to 2.We start
        %index 2 because we want to end function 1 before we start function
        %2.
        
        size_of_location_of_functions_in_array = size(location_of_functions_in_array);
        %The size of the location of functions is required to set up
        %looping constructs. 
        
        %The location of functions array contains the location of functions
        %inside the matlab file which was read line by line. We need
        %endfunction commands to go at the end of each function or before
        %the start of a new function.I went after the location of the start
        %of new functions in an .m file and added 'endfunction' for the
        %function which ended. 
        
        for z = 1:size_of_modified_code_array(1,1)
            
            if z ~= location_of_functions_in_array(function_index,1)-1
                %Unless loop is at one index before the start of a new
                %function,there are no changes to the code. So it is
                %printed to the output octave file as it is. 
                
                fprintf(octave_file_handle,'%s\n',modified_code_array{z});
                
            else
                %If the loop is exactly at one index before the start of
                %a new function, then this step will end the previous
                %function by putting 'endfunction' in a new line after
                %printing the contents of the cell array at that index.
                %I know this all confusing.But I have written code as it
                %sounds. 
                fprintf(octave_file_handle,'%s\nendfunction\n\n',modified_code_array{z});
                
                if function_index < size_of_location_of_functions_in_array(1,1)
                    
                    function_index = function_index + 1;%Function counter 
                    %is incremented to change the looping constructs. 
                    
                end
                
            end
            
        end
        
        fprintf(octave_file_handle,'%s\n','endfunction');%We have achieved 
        %the task of putting all 'endfunction' to all but one function in
        %the .m file. So we end that function by attaching 'endfunction' to
        %the last line of the .m file. This might be one of the bugs which
        %might cause problems for certain people who write comments at the end 
        %of the last function in a .m file. So this issue is also being worked on to be
        %resolved. 
        
    elseif function_counter == 1%If there is exactly one function in a .m file
        %this sequence is run.
        
        for z = 1:size_of_modified_code_array(1,1)
            
            
            fprintf(octave_file_handle,'%s\n',modified_code_array{z});
            %All the lines are printed as it is because we only have one
            %function. 
            
        end
        
        fprintf(octave_file_handle,'%s\n','endfunction');%The function is 
        %ended by putting 'endfunction' at the last line of the .m file
        %contents. This might be one of the bugs which
        %might cause problems for certain people who write comments at the end 
        %of the .m file. So this issue is also being worked on to be
        %resolved. 
        
    else%It the converted .m file is just a script, then we just print the 
        %compatible octave code the file with out any addition. 
        
        for z = 1:size_of_modified_code_array(1,1)
            
            
            fprintf(octave_file_handle,'%s\n',modified_code_array{z});
            
        end
        
    end
    
              
    fclose(octave_file_handle);%Octave file is closed
    
    fclose(matlab_file_handle);%Matlab file is also closed. 
    
%The second version operates on the same code for the most part except that
%user provides the path to store the octave file. 
    
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
    
    matlab_file_handle = fopen(path_to_matlab_file,'r');
    
    line_by_line_reading = fgetl(matlab_file_handle);
    
    while ischar(line_by_line_reading)
        
        matlab_file_as_array=[matlab_file_as_array;line_by_line_reading];
        
        line_by_line_reading = fgetl(matlab_file_handle);
        
    end
    
    modified_code_array = codeModifier(matlab_file_as_array);
    
    [function_counter,location_of_functions_in_array] = findAndLocateFunction(modified_code_array);
    
    size_of_modified_code_array = size(modified_code_array);
    
    if function_counter > 1
        
        function_index = 2;
        
        size_of_location_of_functions_in_array = size(location_of_functions_in_array);
        
        for z = 1:size_of_modified_code_array(1,1)
            
            if z ~= location_of_functions_in_array(function_index,1)-1
                
                fprintf(octave_file_handle,'%s\n',modified_code_array{z});
                
            else
                
                fprintf(octave_file_handle,'%s\nendfunction\n\n',modified_code_array{z});
                
                if function_index < size_of_location_of_functions_in_array(1,1)
                    
                    function_index = function_index + 1;
                    
                end
                
            end
            
        end
        
        fprintf(octave_file_handle,'%s\n','endfunction');
        
    elseif function_counter == 1
        
        for z = 1:size_of_modified_code_array(1,1)
            
            
            fprintf(octave_file_handle,'%s\n',modified_code_array{z});
            
        end
        
        fprintf(octave_file_handle,'%s\n','endfunction');
        
    else
        
        for z = 1:size_of_modified_code_array(1,1)
            
            
            fprintf(octave_file_handle,'%s\n',modified_code_array{z});
            
        end
        
    end
    
      
    fclose(octave_file_handle);
    
    fclose(matlab_file_handle);
    
    
    
end

function [no_of_functions,function_location] = findAndLocateFunction(input_array)

%findAndLocateFunction(input_array) find the total number of function
%inside the cell array and also creates a matrix with their location on the
%cell array. 
%
size_of_input = size(input_array);

function_counter = 0;%function counter is initialized to 0

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);%each row is extracted from the given 
    %cell array
    
    function_locator = strfind(current_row,'function');%each row is searched
    %for the word function. The locator produces a cell array with either
    %an empty matrix or a matrix with the location to indicate whether it
    %has found the word function or not. 
        
    cell_expansion = function_locator{1};%That cell array is expanded. 
    
    if isempty(cell_expansion)%It is empty,it is ignored and we move on to 
        %next row. 
        
    else%if not the function counter is incremented by 1 and the the current
        %value of x is noted down. 
        
        function_counter = function_counter + 1;
        
        function_location(function_counter,1) = x;
        
    end
    
end

no_of_functions = function_counter;%both the function counter and function_location
%are returned. 

function output = functionNameModifier(input_array,function_name)

%The following function is a reimplementation of the findAndLocateFunction
%function with slight changes. Instead of looking for all the functions it
%just looks for the first function because it is the main function.It
%changes the name of it by appending 'Octave' to the end of it to avoid
%warnings when executed in Octave.This function is applicable only to the
%first version of matlab2octave implementation. 

size_of_input = size(input_array);

modified_function_name = [function_name 'Octave'];

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    function_name_modifier = strfind(current_row,function_name);
    
    cell_expansion = function_name_modifier{1};
    
    if isempty(cell_expansion) == 0
        
        current_row = strrep(current_row,function_name,modified_function_name);
        
        input_array(x,1) = current_row;
        
        break;
            
    end
    
end 

output = input_array;
    
    
    
    
    






































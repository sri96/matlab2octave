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
        
        
    end
    
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
        
        
        
    end
    
end



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
    
    if ispc()
        
        output_octave_file_name = [pathExtractor(path_to_matlab_file) '\' matlab_function_name '_octave.m'];
        %Path to save the octave .m file is created.
        
    else
        
        output_octave_file_name = [pathExtractor(path_to_matlab_file) '/' matlab_function_name '_octave.m'];
        
    end
    
    octave_file_handle = fopen(output_octave_file_name,'w');%The octave .m
    %file is created using the path created in the last step and is opened
    %for writing.
    
    
    %The following code block reads the matlab file line by line and
    %creates a cell array with each line of the matlab file as cell.This
    %code was inspired by a question in stackoverflow.
    
    matlab_file_as_array = readFileLineByLine(path_to_matlab_file);
    
    
    [modified_code_array,function_counter,location_of_functions_in_array] = codeModifier(matlab_file_as_array);
    
    if function_counter ~= 0
        
        modified_code_array = functionEnder(modified_code_array,location_of_functions_in_array,function_counter);
        
        modified_code_array = functionNameModifier(modified_code_array,matlab_function_name,location_of_functions_in_array);
        
    end
    
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
    
    if strcmpi(pathExtractor(path_to_matlab_file),path_to_save_octave_file) == 0
        
        
        
        if exist(path_to_save_octave_file,'dir') == 0
            
            mkdir(path_to_save_octave_file);
            
        end
        
        matlab_function_name = functionNameExtractor(path_to_matlab_file);
        
        output_octave_file_name = [path_to_save_octave_file '\' matlab_function_name '.m'];
        
        octave_file_handle = fopen(output_octave_file_name,'w');
        
        matlab_file_as_array = readFileLineByLine(path_to_matlab_file);
        
        [modified_code_array,function_counter,location_of_functions_in_array] = codeModifier(matlab_file_as_array);
        
        if function_counter ~= 0
            
            modified_code_array = functionEnder(modified_code_array,location_of_functions_in_array,function_counter);
            
        end
        
        size_of_modified_code_array = size(modified_code_array);
        %Size of the modified compatible octave code is needed to set up the
        %looping constructs.
        
        for n = 1:size_of_modified_code_array
            
            fprintf(octave_file_handle,'%s\n',modified_code_array{n});
            
        end
        
        
        fclose(octave_file_handle);
        
    else
        
        singleFileConverter(path_to_matlab_file);
        
    end
    
    
end

%fullFolderConverter function grabs the contents of the folder and finds
%all the .m files using the built in dir function. Then it runs through the
%loop sending each function to the singleFileConverter function with
%corresponding inputs.

function fullFolderConverter(varargin)

size_of_varargin = size(varargin);

if size_of_varargin(1,2) == 1
    
    path_to_directory = varargin{1};
    
    if path_to_directory(end) == '\'
        
        path_to_directory = path_to_directory(1:end-1);
        
    end
    
    directory_listing = dir(path_to_directory);
    
    size_of_directory_listing = size(directory_listing);
    
    for x = 3:size_of_directory_listing(1,1)
        
        current_file = directory_listing(x).name;
        
        is_m_file = strfind(current_file,'.m');
        
        if isempty(is_m_file) == 0
            
            path_to_file = [path_to_directory '\' current_file];
            
            singleFileConverter(path_to_file);
            
        end
        
        
    end
    
elseif size_of_varargin(1,2) == 2
    
    
    path_to_directory = varargin{1};
    
    path_to_save_files_directory = varargin{2};
    
    if path_to_directory(end) == '\'
        
        path_to_directory = path_to_directory(1:end-1);
        
    end
    
    if strcmpi(path_to_directory,path_to_save_files_directory) == 0
        
        if exist(path_to_save_files_directory,'dir') == 0
            
            mkdir(path_to_save_files_directory);
            
        end
        
        directory_listing = dir(path_to_directory);
        
        size_of_directory_listing = size(directory_listing);
        
        for x = 3:size_of_directory_listing(1,1)
            
            current_file = directory_listing(x).name;
            
            is_m_file = strfind(current_file,'.m');
            
            if isempty(is_m_file) == 0
                
                path_to_file = [path_to_directory '\' current_file];
                
                singleFileConverter(path_to_file,path_to_save_files_directory);
                
            end
            
            
        end
        
    else
        
        fullFolderConverter(path_to_directory);
        
    end
    
end



function output = functionNameModifier(input_array,function_name,location_of_functions_in_array)

%functionNameModifier function changes the name of the octave main
%functions to prevent warnings from the octave interpreter because of name
%mismatch.

modified_function_name = [function_name '_octave'];

main_function_in_array = input_array{location_of_functions_in_array(1,1),1};

replacement_of_name = strrep(main_function_in_array,function_name,modified_function_name);

input_array{location_of_functions_in_array(1,1),1} = replacement_of_name;


output = input_array;


function output = functionEnder(input_array,location_of_functions,function_counter)

%functionEnder puts the 'endfunction' closure on all the functions in an .m
%file.

size_of_input_array = size(input_array);

location_of_functions = [location_of_functions;size_of_input_array(1,1)+1];

final_cell_array = {};

for x = 1:function_counter
    
    interim_cell_array = input_array(location_of_functions(x,1):location_of_functions(x+1,1)-1,:);
    
    interim_cell_array = [interim_cell_array; 'endfunction'];
    
    final_cell_array = [final_cell_array; interim_cell_array];
    
end

output = final_cell_array;


function output = readFileLineByLine(path_to_file)

%readFileLineByLine function reads any file and returns the contents of it
%as a cell array with each line of the function as cell.

file_id = fopen(path_to_file);

file_as_line_by_line_array = {};

individual_line = fgets(file_id);

file_as_line_by_line_array = [file_as_line_by_line_array ; individual_line];

while ischar(individual_line)
    
    individual_line = fgets(file_id);
    file_as_line_by_line_array = [file_as_line_by_line_array ;individual_line];
    
end

fclose(file_id);

file_as_line_by_line_array(end) = [];

end_of_file = file_as_line_by_line_array{end};

size_of_end_of_file = size(end_of_file);

while size_of_end_of_file(1,2) == 2
    
    file_as_line_by_line_array(end) = [];
    
    end_of_file = file_as_line_by_line_array{end};
    
    size_of_end_of_file = size(end_of_file);
    
end

output = file_as_line_by_line_array;


function [output,no_of_functions,location_of_functions] = codeModifier(input_string_array)

%codeModifier(input_string_array) is the heart of the matlab2octave
%converter because it converts the matlab code into octave compatible
%code.Currently it only has limited capabilities because the conversion
%process is straight forward from matlab to octave.It converts the code
%using seven subfunctions
%
%   removeTrailingWhiteSpace()
%   functionSyntaxMatcher()
%   ifSyntaxModifier()
%   forSyntaxModifier()
%   whileSyntaxModifier()
%   switchSyntaxModifier()
%   tryCatchSyntaxModifier()
%   functionSyntaxModifier()-This is under development.The source code as
%   it stands is given. It has been tested and proven to give unwanted
%   results. So please refrain from using it.
%
%The names are self explanatory of what those functions do. They just tweak
%the corresponding matlab constructs to make them octave compatible. We
%only identified two major differences that needed to be taken care of
%while converting from matlab to octave. One is the syntax difference
%between both languages. The next is octave doesn't support nested
%functions as of right now. So we are working on adding nested function
%detection and intimating the user about the presence of it.
%
%The philosophy behind writing seperate functions to take care of different
%things is to enable easy bug fixing when issues arise.
%
%Bug Fixes:
%removeTrailingWhiteSpace function was added as a bug fix to fix
%inconsistent formatting which caused incompatibility with the produced
%octave code(Added July 20,2012).
%
%elseif bug fix was added to ifModifier() function to fix problems arising
%from elseif statements present with in matlab's if conditional constructs.
%(Added July 20,2012) (Removed July 22,2012)
%
%isComment function was added as a bug fix to avoid parsing and replacing
%'if','for','while' and switch statements contained with in comments.
%(Added July 20,2012)
%
%tryCatchSytaxModifier function was added as a bug fix to to modify try
%catch statements. (Added August 25,2012)
%
%All the functions have been re-written to fix lots of bugs that were
%giving a lot of trouble.One bug has been left unfixed because the probablity of somebody encountering it is very low.
%Please read the known issues section on our documentation to read more
%about the bugs and also about other issues for which solution is being
%worked out. (Added July 22,2012)
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

output = removeTrailingWhiteSpace(input_string_array);

[no_of_functions,location_of_functions] = functionSyntaxMatcher(output);

output = ifSyntaxModifier(output);

output = forSyntaxModifier(output);

output = whileSyntaxModifier(output);

output = switchSyntaxModifier(output);

output = tryCatchSyntaxModifier(output);

%output = functionSyntaxModifier(output);This feature is under development
%specially for people who put 'end' at the last line of a function.If you
%are one of those people,please don't use this converter because it will
%completely mess your code up.


%The following functions add syntax modifications to the matlab code to
%make it octave compatible.Please read the octave and matlab documentation
%to know more about the syntax.


function input_string_cell_array = ifSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)%For loop runs through the whole array
    
    current_row = input_string_cell_array{x,1};%for each iteration one row
    %is extracted from the array. We will use this to easily identify the
    %corresponding constructs
    
    replacement_string_1 = input_string_cell_array{x,1};%this is a duplicate
    %step of the above statement. We will use this to actually tweak the
    %constructs
    
    current_row = strtrim(current_row);%The row is stripped off all the whitespaces
    %both trailing and the ones at the starting of a string
    
    if isWholeLineComment(current_row) == 0%If the string is just a full line comment
        %we can ignore it
        
        current_row = commentlessString(current_row);%this step removes inline
        %comments from strings so that we can concentrate what will be
        %executed
        
        if_locator = strfind(current_row,'if');%It searches through each row
        %to find out if it contains an if statement. This brings up some
        %interesting things like words that contain 'if' like 'modified' as
        %a possibility. The nest few steps will eliminate those false
        %positives
        
        
        if isempty(if_locator) == 0%If there is not if statement on a row,
            %we simply ignore it.
            
            [token,remain] = strtok(current_row);%If conditional construct
            %usually occurs at the start of a statement and is usually
            %followed by a space.So we check for that below
            
            if strcmp(token,'if')%It it matches our criteria we have found real
                %if statements
                
                if_locator_2 = strfind(commentlessString(replacement_string_1),'if');%Now we use the duplicate string to find out the position of
                %if in a row.Position in a row is important because my
                %function exploits matlab's auto align feature to tweak
                %code.
                
                size_of_if_locator_2 = size(if_locator_2);
                
                if size_of_if_locator_2(1,2) > 1
                    
                    if_locator_2 = if_locator_2(1,1);
                    
                end
                
                for y = x:size_of_input(1,1)%a for loop goes through the
                    %array to find a matching 'end' statement which has the
                    %same alignment in the row and position. Once it has
                    %found a match, it eliminates false positives through
                    %the method used by if construct. Once it has decided
                    %on the best fit, it appends 'if' to the 'end'
                    %statement to make it octave compatible.
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isWholeLineComment(current_row) == 0
                        
                        current_row_2 = commentlessString(current_row_2);
                        
                        end_locator = strfind(current_row_2,'end');
                        
                        if isempty(end_locator) == 0
                            
                            if strcmp(current_row_2,'end')
                                
                                end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
                                
                                if if_locator_2 == end_locator_2
                                    
                                    replacement_string_2 = [replacement_string_2 'if'];
                                    
                                    input_string_cell_array{y,1} = replacement_string_2;
                                    
                                    break
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                
            end
            
            
            
        end
        
        
    end
    
end

%All the below functions are replications of ifSyntaxModifier function to
%work on other constructs.

function input_string_cell_array = forSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isWholeLineComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        for_locator = strfind(current_row,'for');
        
        
        if isempty(for_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'for')
                
                for_locator_2 = strfind(commentlessString(replacement_string_1),'for');
                
                size_of_for_locator_2 = size(for_locator_2);
                
                if size_of_for_locator_2(1,2) > 1
                    
                    for_locator_2 = for_locator_2(1,1);
                    
                end
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isWholeLineComment(current_row) == 0
                        
                        current_row_2 = commentlessString(current_row_2);
                        
                        end_locator = strfind(current_row_2,'end');
                        
                        if isempty(end_locator) == 0
                            
                            if strcmp(current_row_2,'end')
                                
                                end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
                                
                                if for_locator_2 == end_locator_2
                                    
                                    replacement_string_2 = [replacement_string_2 'for'];
                                    
                                    input_string_cell_array{y,1} = replacement_string_2;
                                    
                                    break
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                
            end
            
            
            
        end
        
        
    end
    
end

function input_string_cell_array = whileSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isWholeLineComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        while_locator = strfind(current_row,'while');
        
        
        if isempty(while_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'while')
                
                while_locator_2 = strfind(commentlessString(replacement_string_1),'while');
                
                size_of_while_locator_2 = size(while_locator_2);
                
                if size_of_while_locator_2(1,2) > 1
                    
                    while_locator_2 = while_locator_2(1,1);
                    
                end
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isWholeLineComment(current_row) == 0
                        
                        current_row_2 = commentlessString(current_row_2);
                        
                        end_locator = strfind(current_row_2,'end');
                        
                        if isempty(end_locator) == 0
                            
                            if strcmp(current_row_2,'end')
                                
                                end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
                                
                                if while_locator_2 == end_locator_2
                                    
                                    replacement_string_2 = [replacement_string_2 'while'];
                                    
                                    input_string_cell_array{y,1} = replacement_string_2;
                                    
                                    break
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                
            end
            
            
            
        end
        
        
    end
    
end


function input_string_cell_array = switchSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isWholeLineComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        switch_locator = strfind(current_row,'switch');
        
        
        if isempty(switch_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'switch')
                
                switch_locator_2 = strfind(commentlessString(replacement_string_1),'switch');
                
                size_of_switch_locator_2 = size(switch_locator_2);
                
                if size_of_switch_locator_2(1,2) > 1
                    
                    switch_locator_2 = switch_locator_2(1,1);
                    
                end
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isWholeLineComment(current_row) == 0
                        
                        current_row_2 = commentlessString(current_row_2);
                        
                        end_locator = strfind(current_row_2,'end');
                        
                        if isempty(end_locator) == 0
                            
                            if strcmp(current_row_2,'end')
                                
                                end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
                                
                                if switch_locator_2 == end_locator_2
                                    
                                    replacement_string_2 = [replacement_string_2 'switch'];
                                    
                                    input_string_cell_array{y,1} = replacement_string_2;
                                    
                                    break
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                
            end
            
            
            
        end
        
        
    end
    
end

function [function_counter,function_location] = functionSyntaxMatcher(input_string_cell_array)

size_of_input = size(input_string_cell_array);

function_counter = 0;

function_location = [];

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isWholeLineComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        function_locator = strfind(current_row,'function');
        
        
        if isempty(function_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'function')
                
                function_counter = function_counter + 1;
                
                function_location(function_counter,1) = x;
                
                
            end
            
        end
        
        
    end
    
    
end

%removeTrailingWhiteSpace function is self explanatory.

function input_array = removeTrailingWhiteSpace(input_array)

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    current_row = deblank(current_row);
    
    input_array(x,1) = current_row;
    
end


function output = isWholeLineComment(input_string)

%isWholeLineComment function identifies comments by searching for the percentage
%sign in the code. If it is found as the first character in the string,
%then the function can tell that it is a comment.

input_string = strtrim(input_string);

comment_finder = strfind(input_string,'%');

if isempty(comment_finder) == 0
    
    if comment_finder == 1
        
        output = 1;
        
    else
        
        output = 0;
        
    end
    
else
    
    output = 0;
    
end

function output_string = commentlessString(input_string)

%commentlessString function identifies inline comments and strips them to
%return back executable code.This code is necessary to identify and
%manipulate constructs.

comment_location = strfind(input_string,'%');

parsableString = input_string;

if isempty(comment_location) == 0
    
    parsableString = input_string(1:comment_location-1);
    
end

output_string = parsableString;

function input_string_cell_array = tryCatchSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isWholeLineComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        for_locator = strfind(current_row,'try');
        
        
        if isempty(for_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'try')
                
                for_locator_2 = strfind(commentlessString(replacement_string_1),'try');
                
                size_of_for_locator_2 = size(for_locator_2);
                
                if size_of_for_locator_2(1,2) > 1
                    
                    for_locator_2 = for_locator_2(1,1);
                    
                end
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isWholeLineComment(current_row) == 0
                        
                        current_row_2 = commentlessString(current_row_2);
                        
                        end_locator = strfind(current_row_2,'end');
                        
                        if isempty(end_locator) == 0
                            
                            if strcmp(current_row_2,'end')
                                
                                end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
                                
                                if for_locator_2 == end_locator_2
                                    
                                    replacement_string_2 = [replacement_string_2 '_try_catch'];
                                    
                                    input_string_cell_array{y,1} = replacement_string_2;
                                    
                                    break
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                
            end
            
            
            
        end
        
        
    end
    
end

function output = functionNameExtractor(input_path)

%functionNameExtractor(input_path) extracts the name of the .m file from
%the path.The process is straight forward.

m_extension_removal = strfind(input_path,'.m');%finding the .m extension

remaining_string = input_path(1:m_extension_removal-1);%removing the .m
%extension

if ispc() == 1
    
    correct_slash_finder = strfind(remaining_string,'\');%find all the forward
    %slash in the remaining input path
    
    if isempty(correct_slash_finder)
        
        output = remaining_string;
        
    else
        
        output = input_path(correct_slash_finder(end)+1:m_extension_removal-1);
        %Extract the string from the last forward slash to start of the m
        %extension. The obtained string will be the name of the function.
        
    end
    
else
    
    correct_slash_finder = strfind(remaining_string,'/');
    
    if isempty(correct_slash_finder)
        
        output = remaining_string;
        
    else
        
        output = input_path(correct_slash_finder(end)+1:m_extension_removal-1);
        %Extract the string from the last forward slash to start of the m
        %extension. The obtained string will be the name of the function.
        
    end
    
end



function output = pathExtractor(input_path)

%pathExtractor(input_path) is a reimplementation of functionNameExtractor
%function in which instead of returning the name of the function from path,
%this function just returns the remaining string after removing the
%function name and .m extension.

m_extension_removal = strfind(input_path,'.m');

remaining_string = input_path(1:m_extension_removal-1);

if ispc() == 1
    
    correct_slash_finder = strfind(remaining_string,'\');%find all the forward
    %slash in the remaining input path
    
    if isempty(correct_slash_finder)
        
        output = pwd;
        
    else
        
        output = input_path(1:correct_slash_finder(end)-1);
        
    end
    
else
    
    correct_slash_finder = strfind(remaining_string,'/');
    
    if isempty(correct_slash_finder)
        
        output = pwd;
        
    else
        
        output = input_path(1:correct_slash_finder(end)-1);
        
    end
    
end



















































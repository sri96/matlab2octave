function [output,no_of_functions,location_of_functions] = codeModifier(input_string_array)

%codeModifier(input_string_array) is the heart of the matlab2octave
%converter because it converts the matlab code into octave compatible
%code.Currently it only has limited capabilities because the conversion
%process is straight forward from matlab to octave.It converts the code
%using five subfunctions
%
%   removeTrailingWhiteSpace()
%   ifModifier()
%   forModifier()
%   whileModifier()
%   switchModifier()
%
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
%(Added July 20,2012)
%
%isComment function was added as a bug fix to avoid parsing and replacing
%'if','for','while' and switch statements contained with in comments.
%(Added July 20,2012)
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

[no_of_functions,location_of_functions] = functionSyntaxMatcher(output)

output = ifSyntaxModifier(output);

output = forSyntaxModifier(output);

output = whileSyntaxModifier(output);

output = switchSyntaxModifier(output);


%The following functions add syntax modifications to the matlab code to
%make it octave compatible.Please read the octave and matlab documentation
%to know more about the syntax.


function input_string_cell_array = ifSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        if_locator = strfind(current_row,'if');
        
        
        if isempty(if_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'if')
                
                if_locator_2 = strfind(commentlessString(replacement_string_1),'if');
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isComment(current_row) == 0
                        
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

function input_string_cell_array = forSyntaxModifier(input_string_cell_array)

size_of_input = size(input_string_cell_array);

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    replacement_string_1 = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        for_locator = strfind(current_row,'for');
        
        
        if isempty(for_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'for')
                
                for_locator_2 = strfind(commentlessString(replacement_string_1),'for');
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isComment(current_row) == 0
                        
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
    
    if isComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        while_locator = strfind(current_row,'while');
        
        
        if isempty(while_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'while')
                
                while_locator_2 = strfind(commentlessString(replacement_string_1),'while');
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isComment(current_row) == 0
                        
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
    
    if isComment(current_row) == 0
        
        current_row = commentlessString(current_row);
        
        switch_locator = strfind(current_row,'switch');
        
        
        if isempty(switch_locator) == 0
            
            [token,remain] = strtok(current_row);
            
            if strcmp(token,'switch')
                
                switch_locator_2 = strfind(commentlessString(replacement_string_1),'switch');
                
                for y = x:size_of_input(1,1)
                    
                    current_row_2 = input_string_cell_array{y,1};
                    
                    replacement_string_2 = input_string_cell_array{y,1};
                    
                    current_row_2 = strtrim(current_row_2);
                    
                    if isComment(current_row) == 0
                        
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

for x = 1:size_of_input(1,1)
    
    current_row = input_string_cell_array{x,1};
    
    current_row = strtrim(current_row);
    
    if isComment(current_row) == 0
        
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


function output = isComment(input_string)

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

comment_location = strfind(input_string,'%');

parsableString = input_string;

if isempty(comment_location) == 0
    
    parsableString = input_string(1:comment_location-1);
    
end

output_string = parsableString;
























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































function output = codeModifier(input_string_array)

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

output = ifModifier(output);

output = forModifier(output);

output = whileModifier(output);

output = switchModifier(output);

%The following functions add syntax modifications to the matlab code to
%make it octave compatible.Please read the octave and matlab documentation
%to know more about the syntax. 


function output = ifModifier(input_array)

%ifModifier(input_array) finds all the 'if' statments and their corresponding
%'end' statements. Once it finds matching 'end' statements it converts them
%into 'endif' statements. 

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    if_locator = strfind(current_row,'if');
    
    
    cell_expansion = if_locator{1};
    
    if isempty(cell_expansion)
        
    else
        
        %Added to fix the elseif bug which was appending multiple ifs to
        %the same end statements.(Added July 20,2012)
        else_if_locator = strfind(current_row,'elseif');
        
        cell_expansion_2 = else_if_locator{1};
        
        if isempty(cell_expansion_2)
            
            
            for y = x:size_of_input(1,1)
                
                current_row_2 = input_array(y,1);
                
                end_locator = strfind(current_row_2,'end');
                
                cell_expansion_3 = end_locator{1};
                
                if isempty(cell_expansion_3) == 0
                    
                    if cell_expansion(1,1) == cell_expansion_3(1,1)
                        
                        
                        if_code_modifier = current_row_2{1};
                        
                        if_code_modifier = [if_code_modifier 'if'];
                        
                        current_row_2{1} = if_code_modifier;
                        
                        input_array(y,1) = current_row_2;
                        
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

output = input_array;

%forModifier,whileModifier and switchModifier are reimplementations of
%ifModifier modified with commands looking and replacing appropriate
%constructs. 

function output = forModifier(input_array)

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    for_locator = strfind(current_row,'for');
    
    
    cell_expansion = for_locator{1};
    
    if isempty(cell_expansion)
        
    else
        
        
        for y = x:size_of_input(1,1)
            
            current_row_2 = input_array(y,1);
            
            end_locator = strfind(current_row_2,'end');
            
            cell_expansion_3 = end_locator{1};
            
            if isempty(cell_expansion_3) == 0
                
                if cell_expansion(1,1) == cell_expansion_3(1,1)
                    
                    
                    for_code_modifier = current_row_2{1};
                    
                    for_code_modifier = [for_code_modifier 'for'];
                    
                    current_row_2{1} = for_code_modifier;
                    
                    input_array(y,1) = current_row_2;
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
end

output = input_array;

function output = whileModifier(input_array)

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    while_locator = strfind(current_row,'while');
    
    
    cell_expansion = while_locator{1};
    
    if isempty(cell_expansion)
        
    else
        
        
        for y = x:size_of_input(1,1)
            
            current_row_2 = input_array(y,1);
            
            end_locator = strfind(current_row_2,'end');
            
            cell_expansion_3 = end_locator{1};
            
            if isempty(cell_expansion_3) == 0
                
                if cell_expansion(1,1) == cell_expansion_3(1,1)
                    
                    
                    while_code_modifier = current_row_2{1};
                    
                    while_code_modifier = [while_code_modifier 'while'];
                    
                    current_row_2{1} = while_code_modifier;
                    
                    input_array(y,1) = current_row_2;
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
end

output = input_array;

function output = switchModifier(input_array)

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    switch_locator = strfind(current_row,'switch');
    
    
    cell_expansion = switch_locator{1};
    
    if isempty(cell_expansion)
        
    else
        
        
        for y = x:size_of_input(1,1)
            
            current_row_2 = input_array(y,1);
            
            end_locator = strfind(current_row_2,'end');
            
            cell_expansion_3 = end_locator{1};
            
            if isempty(cell_expansion_3) == 0
                
                if cell_expansion(1,1) == cell_expansion_3(1,1)
                    
                    
                    switch_code_modifier = current_row_2{1};
                    
                    switch_code_modifier = [switch_code_modifier 'switch'];
                    
                    current_row_2{1} = switch_code_modifier;
                    
                    input_array(y,1) = current_row_2;
                    
                    break
                    
                end
                
            end
            
        end
        
    end
    
end

output = input_array;

%removeTrailingWhiteSpace function is self explanatory. 

function output = removeTrailingWhiteSpace(input_array)

size_of_input = size(input_array);

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    current_row = deblank(current_row);
    
    input_array(x,1) = current_row;
    
end 

output = input_array;









































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































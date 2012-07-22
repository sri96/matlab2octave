function [output,no_of_functions,location_of_functions] = codeModifier(input_string_array)

%codeModifier(input_string_array) is the heart of the matlab2octave
%converter because it converts the matlab code into octave compatible
%code.Currently it only has limited capabilities because the conversion
%process is straight forward from matlab to octave.It converts the code
%using five subfunctions
%
%   removeTrailingWhiteSpace()
%   functionSyntaxMatcher()
%   ifSyntaxModifier()
%   forSyntaxModifier()
%   whileSyntaxModifier()
%   switchSyntaxModifier()
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
%All the functions have been re-written to fix lots of bugs that were
%giving a lot of trouble.One bug has been left unfixed because the probablity of somebody encountering it is very low.
%Please read the known issues section on our documentation to read more
%about the bug and also about other issues for which solution is being
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

% function input_string_cell_array = functionSyntaxModifier(input_string_cell_array)
% 
% size_of_input = size(input_string_cell_array);
% 
% for x = 1:size_of_input(1,1)
%     
%     current_row = input_string_cell_array{x,1};
%     
%     replacement_string_1 = input_string_cell_array{x,1};
%     
%     current_row = strtrim(current_row);
%     
%     if isWholeLineComment(current_row) == 0
%         
%         current_row = commentlessString(current_row);
%         
%         function_locator = strfind(current_row,'function');
%         
%         
%         if isempty(function_locator) == 0
%             
%             [token,remain] = strtok(current_row);
%             
%             if strcmp(token,'function')
%                 
%                 function_locator_2 = strfind(commentlessString(replacement_string_1),'function');
%                 
%                 for y = x:size_of_input(1,1)
%                     
%                     current_row_2 = input_string_cell_array{y,1};
%                     
%                     replacement_string_2 = input_string_cell_array{y,1};
%                     
%                     current_row_2 = strtrim(current_row_2);
%                     
%                     if isWholeLineComment(current_row) == 0
%                         
%                         current_row_2 = commentlessString(current_row_2);
%                         
%                         end_locator = strfind(current_row_2,'end');
%                         
%                         if isempty(end_locator) == 0
%                             
%                             if strcmp(current_row_2,'end')
%                                 
%                                 end_locator_2 = strfind(commentlessString(replacement_string_2),'end');
%                                 
%                                 if function_locator_2 == end_locator_2
%                                     
%                                     replacement_string_2 = [replacement_string_2 'function'];
%                                     
%                                     input_string_cell_array{y,1} = replacement_string_2;
%                                     
%                                     break
%                                     
%                                 end
%                                 
%                             end
%                             
%                         end
%                         
%                     end
%                     
%                 end
%                 
%                 
%             end
%             
%             
%             
%         end
%         
%         
%     end
%     
% end
% 


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



























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































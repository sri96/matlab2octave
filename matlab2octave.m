function matlab2octave(A,B)

if B(end) == '\'
    
    B = B(1:end-1);
    
end

if strcmpi(pathExtractor(A),B)
    
    C = functionNameExtractor(A);
    
    D = [B '\' C 'Octave.m'];
    
    f = fopen(D,'w');
    
    f1 = fopen(A,'r');
    
    s={};
    
    tline = fgetl(f1);
    
    while ischar(tline)
        
        s=[s;tline];
        
        tline = fgetl(f1);
        
    end
    
    
    H = codeModifier(s);
    
    [I,J] = findAndLocateFunction(H);
    
    size_of_input = size(H);
    
    function_incrementer = 2;
    
    size_of_location = size(J);
    
    for z = 1:size_of_input(1,1)
        
        if z ~= J(function_incrementer,1)-1
            
            fprintf(f,'%s\n',H{z});
            
        else
            
            fprintf(f,'%s\nendfunction\n\n',H{z});
            
            if function_incrementer < size_of_location(1,1)
                
                function_incrementer = function_incrementer + 1;
                
            end
            
        end
        
    end
    
    fprintf(f,'%s\n','endfunction');
    
    fclose(f);
    
    fclose(f1);
    
else
    
    C = functionNameExtractor(A);
    
    D = [B '\' C '.m'];
    
    f = fopen(D,'w');
    
    f1 = fopen(A,'r');
    
    tline = fgetl(f1);
    
    while ischar(tline)
        
        s=[s;tline];
        
        tline = fgetl(f1);
        
    end
    
    H = codeModifier(s);
    
    [I,J] = findAndLocateFunction(H);
    
    size_of_input = size(H);
    
    function_incrementer = 2;
    
    size_of_location = size(J);
    
    for z = 1:size_of_input(1,1)
        
        if z ~= J(function_incrementer,1)-1
            
            fprintf(f,'%s\n',H{z});
            
        else
            
            fprintf(f,'%s\nendfunction\n\n',H{z});
            
            if function_incrementer < size_of_location(1,1)
                
                function_incrementer = function_incrementer + 1;
                
            end
            
        end
        
    end
    
    fprintf(f,'%s\n','endfunction');
    
    fclose(f);
    
    fclose(f1);
    
    
    
end

function [no_of_functions,function_location] = findAndLocateFunction(input_array)

size_of_input = size(input_array);

function_counter = 0;

for x  = 1:size_of_input(1,1)
    
    current_row = input_array(x,1);
    
    function_locator = strfind(current_row,'function');
    
    
    cell_expansion = function_locator{1};
    
    if isempty(cell_expansion)
        
    else
        
        function_counter = function_counter + 1;
        
        function_location(function_counter,1) = x;
        
    end
    
end

no_of_functions = function_counter;

































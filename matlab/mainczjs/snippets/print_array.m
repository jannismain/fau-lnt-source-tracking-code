function print_array( a, format)
if nargin<2, format="0.1f"; end
    fprintf("[ ");
    for i=1:length(a)
        fprintf(strcat("%",format), a(i));
        if i==length(a)
            fprintf(" ]\n");
        else 
            fprintf(", ")
        end
    end
end


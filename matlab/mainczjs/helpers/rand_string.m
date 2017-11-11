function rnd = rand_string(n)

SET = char(['a':'z' '0':'9']) ;
NSET = length(SET) ;

i = ceil(NSET*rand(1,n)) ; % with repeat
rnd = SET(i) ;

end

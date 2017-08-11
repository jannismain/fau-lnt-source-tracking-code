function path = ensurePath(path)

if isunix
    pos = strfind(path,'\');
    path(pos) = '/';
else
    pos = strfind(path,'/');
    path(pos) = '\';
end


% MAKE tool for MATLAB prompt
%   MAKE - by default executes the content of '.\makefile'. If the file
%   is missing execution is aborded
%   MAKE(filename) - executes the content of the 'filename'. If path is
%   specified in filename, then the directory is changed to the one
%   specified in the path before execution. At the end of execution it
%   returns to the original directory.
%
%   'makefile' syntax:
%   target1 : dependency1[, dependency2, ...]\r\n
%   [matlab command1\r\n
%   matlab command2\r\n
%   ...]
%   \r\n 
%   target2 : dependency1[, dependency2, ...]\r\n
%   [matlab command1\r\n
%   matlab command2\r\n
%   ...]
%   \r\n 
%
%   Advices: avoid the use of white spaces in the filenames; separate
%   targets with '\r\n'; write matlab commands in separate lines; the last
%   target must be followed by an empty line
%
%   Example:
%   result.txt : input.txt, depend.txt\r\n
%       fid=fopen('input.txt')\r\n
%       fclose\r\n
%   \r\n
%   depend.txt: output.txt\r\n
%       fid=fopen('output.txt')\r\n
%   \r\n
%   \EOF
function make(varargin)
initdir=pwd;
switch nargin 
    case 0
        makefile='makefile';
    case 1
        [path,makefile]=getpath(varargin{1});
        if isdir(path) 
            cd(path);
        else 
            display('Directory not found!');
            return;
        end
    otherwise
        display('Too many input arguments');
        return;
end

fid=fopen(makefile,'r+');
if fid == -1
    display('makefile missing!');
    cd(initdir);
    return;
else
    targets=read(fid);
    fclose(fid);
    maketargets(targets);
end
cd(initdir);
display('make ended.');



function [path,makefile]=getpath(makefile)
    index=strfind(makefile,'\');
    if isempty(index)
        path=pwd;
        makefile=makefile;
    else
        path=makefile(1:index(end)-1);
        makefile=makefile(index(end)+1:end);
    end
    
function [principal]=read(fid)
% state mashine diagramm
    principal=node('','');
    while ~feof(fid)
       target=readtarget(fid);
       principal=principal.addchild(target);
    end
    
function target = readtarget(fid)
    % get target
    char=fread(fid,1,'uint8=>char');
    targetname=[];
    while char ~= ':' % target until ':'
        if (char~= ' ') % discard white spaces
            targetname=[targetname,char]; 
        end
        char=fread(fid,1,'uint8=>char');
    end
    target=node(targetname,'');
    %get dependencies
    dependency=[];
    char=fread(fid,1,'uint8=>char');
    while uint8(char) ~= 13 % dependencies until end-of-line
        if char == ','
            dep=node(dependency,'');
            target=target.addchild(dep);
            dependency=[];
        else 
            if char ~= ' ' % discard white spaces
                dependency=[dependency,char];
            end
        end
        char=fread(fid,1,'uint8=>char');
    end
    dep=node(dependency,'');
    target=target.addchild(dep);
    %get commands
    fread(fid,1,'uint8=>char'); %read line feed character
    str=fgets(fid);
    while regexp(str,'\r\n') ~= 1
        target=target.addcommand(str);
        str=fgets(fid);
    end
    
        
function maketargets(current)
    % postorder tree walkthrough
    if isempty(current.children)
        return
    else
        for i=1:current.chldnr
            maketargets(current.children(i));
            process(current.children(i));
        end
    end
        
function process(current)
        t1=current.time;
        if ~isempty(current.parent)
            t2=current.parent.time;
            if t1>t2
                try
                    eval(current.parent.commands);
                catch myexeption
                    display([current.parent.target, ' failed']);
                    display(myexeption.message);
                end
                display([current.parent.target,' timestamp:',datestr(t2)]);
            end
        end

    
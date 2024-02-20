classdef node < handle
    properties
        parent
        children
        chldnr
        target
        commands
    end
    methods
        function obj=node(target, commands)
            obj.target=target;
            obj.commands=commands;
            obj.parent=[];
            obj.children=[];
            obj.chldnr=0;
        end
        function obj2=copy(obj1)
            obj2=node('','');
            obj2.target=obj1.target;
            obj2.commands=obj1.commands;
            obj2.parent=obj1.parent;
            obj2.children=obj1.children;
            obj2.chldnr=obj1.chldnr;
        end
        function obj=addparent(obj,parent)
            obj.parent=parent;
        end
        function obj=addchild(obj,child)
            matches=obj.getmatches(child,[]);
            if isempty(matches)
                obj.children=[obj.children,child];
                child.parent=obj;
                obj.chldnr=obj.chldnr+1;
            else
                for i=1:size(matches)
                    copychild=child.copy;
                    matches(i).children=[matches(i).children,copychild.children];
                    matches(i).commands=[matches(i).commands,copychild.commands];
                    copychild.parent=matches(i);
                    matches(i).chldnr= matches(i).chldnr+copychild.chldnr;
                end
            end
        end
        function obj=addcommand(obj,command)
            obj.commands=[obj.commands,command];
        end 
        function matches=getmatches(obj,child,matches)
            if strcmp(obj.target,child.target)
                matches=[matches,obj];
            end          
            for i=1:obj.chldnr
                matches=obj.children(i).getmatches(child,matches);
            end

        end
        function t=time(obj)
            if strcmp(obj.target,'')
                t=Inf;
            else
                t=0;
                [path,file]=getpath(obj);
                d=dir(path);
                for i=1:size(d)
                    if strcmp(d(i).name,file)
                        t=d(i).datenum;
                        return;
                    end
                end
            end
        end
    end
    methods (Access=private)
        function [path,file]=getpath(obj)

            index=strfind(obj.target,'\');
            if isempty(index)
                path=pwd;
                file=obj.target;
            else
                path=obj.target(1:index(end)-1);
                file=obj.target(index(end)+1:end);
            end    
        end
    end
end
function proba(root)
f=pro_man;
%root = uitreenode('v0', 'receiver', 'receiver', [], false);
%leaf1 = uitreenode('v0', 'receiver', 'bpf', [], true);
%root.add(leaf1)
 t = uitree('v0', f, 'Root', root, 'Position',[0 0 300 400]);
%   t = uitree('v0', 'Root', root, 'ExpandFcn', @myExpfcn, ...
 %              'SelectionChangeFcn', 'disp(''Selection Changed'')');
end
           
function nodes = myExpfcn(tree, value)

    try
        count = 0;
        ch = dir(value);

        for i=1:length(ch)
            if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
                count = count + 1;
                if ch(i).isdir
                    iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
                else
                    iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
                end
                nodes(count) = uitreenode([value, ch(i).name, filesep], ...
                    ch(i).name, iconpath, ~ch(i).isdir);
            end
        end
    catch
    end

    if (count == 0)
        nodes = [];
    end
end
    % ---------------------------------------------

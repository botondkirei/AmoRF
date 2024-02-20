%% Un-installation Script
%
% *Step 1.* Go to the amorf installed directory.
%
% *Step 2.* Run |uninstall.m|.
currpath=pwd;
rmpath [currpath '\amorf'];
rmpath [currpath '\amorfdemos'];
rmpath [currpath '\amorf\attributes'];
rmpath [currpath '\amorf\layers'];

rmpath [currpath '\amorf\derived'];
rmpath [currpath '\amorf\compensation'];
rmpath [currpath '\amorf\signals'];

rmpath [currpath '\amorf\interface'];
rmpath (path,currpath);
savepath;
clear currpath;
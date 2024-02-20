%% Installation Script
%
% *Step 1.* Copy the toolbox in the directory you intend to save.
%
% *Step 2.* Run |install.m|.
currpath=pwd;
addpath(path,[currpath '\amorf']);
addpath(path,[currpath '\amorfdemos']);
addpath(path,[currpath '\amorf\attributes']);
addpath(path,[currpath '\amorf\layers']);

addpath(path,[currpath '\amorf\derived']);
addpath(path,[currpath '\amorf\compensation']);
addpath(path,[currpath '\amorf\signals']);

addpath(path,[currpath '\amorf\interface']);
addpath(path,currpath);
savepath;
clear currpath;
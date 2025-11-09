clear, clf, close all

% Create paths for the PRG, DAT and RES paths
temp = matlab.desktop.editor.getActive;  % Get path for init.m

global PRG_PATH WRK_PATH DAT_PATH RES_PATH
PRG_PATH = dir(temp.Filename).folder;
WRK_PATH = fileparts(PRG_PATH);
DAT_PATH = fullfile(WRK_PATH, "DAT");
RES_PATH = fullfile(WRK_PATH, "RES");

clear temp;

% Change working directory
cd(WRK_PATH);

% Load all directories with functions and scripts inside PRG
addpath(genpath(WRK_PATH))

%% Inform the user
clc
disp("Working directory :")
disp("    " + WRK_PATH)
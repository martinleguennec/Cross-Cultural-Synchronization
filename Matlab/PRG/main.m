%% Main Processing Script
% This script sets up the environment, processes each subject and task, and 
% save results as files in the RES folder

% Initiate the workspace
temp = matlab.desktop.editor.getActive;
cd(fileparts(temp.Filename));
init;

%%
% Set global variables
global tbl_relphase SAMP_FREQ_STIM SAMP_FREQ_MOV RES_PATH;

SAMP_FREQ_STIM = 5000;
SAMP_FREQ_MOV = 500;

tbl_relphase_var_names = {'group', 'subject', 'task', 'task_number', ...
                          'frequency', 'tap', 'DT', ...
                          'period', 'relphase'};
tbl_relphase_var_types = {'string', 'string', 'string', 'double', ...
                          'double', 'double', 'double', ...
                          'double', 'double'};
tbl_relphase = table('Size', [0 9], ...
                     'VariableNames', tbl_relphase_var_names, ...
                     'VariableTypes', tbl_relphase_var_types);

%% Loop through directories
dirs = dir(DAT_PATH);
for dir_idx = 1:length(dirs)
    if startsWith(dirs(dir_idx).name, "XP")
        path_xp_dir = fullfile(dirs(dir_idx).folder, dirs(dir_idx).name);
        dir_name_parts = split(dirs(dir_idx).name, "_");
        group = convertCharsToStrings(dir_name_parts{2});

        disp(" ")
        disp("Group " + group)

        subj_dirs = dir(path_xp_dir);

        for subj_idx = 1:length(subj_dirs)

            % If it is not a subject dir, go to next iteration
            if ~subj_dirs(subj_idx).isdir || startsWith(subj_dirs(subj_idx).name, ".")
                continue;
            end

            path_subj_dir = fullfile(subj_dirs(subj_idx).folder, subj_dirs(subj_idx).name);
            subj = convertCharsToStrings(subj_dirs(subj_idx).name);

            disp("   Subject " + subj) 

            files = dir(path_subj_dir);
            for file_idx = 1:length(files)
                if files(file_idx).isdir || startsWith(files(file_idx).name, ".")
                    continue;
                end
                process_file(files, file_idx, subj, group);
            end
        end
    end
end

clear dirs dir_idx path_xp_dir dir_name_parts group subj_dirs subj_idx path_subj_dir subj files file_idx



%% Save the table and structure
save(fullfile(RES_PATH, 'tbl_relphase.mat'), 'tbl_relphase');
writetable(tbl_relphase, fullfile(RES_PATH, 'tbl_relphase.txt'))

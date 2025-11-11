function plot_movement(fig_num, mov_shape, subj, task, task_number, plat, movement_index, epsi_immobile, epsi_dwell)
    % PLOT_MOVEMENT Plots the specified movement of a given task of a given subject.
    %
    % Author: XXX
    %
    % INPUTS:
    %   subj - String, the subject identifier.
    %   task - String, the task identifier.
    %   task_number - Integer, the task number.
    %   plat - Integer, the plateau number.
    %   movement_index - Integer, the index of the movement to plot.
    %   epsi_immobile - Double, the epsilon value for immobility threshold.
    %   epsi_dwell - Double, the epsilon value for dwelling threshold.
    
    the_plat = sprintf("P%i", plat);
    the_task = sprintf("%s_%i", task, task_number);
    
    if ~isfield(mov_shape.(subj).Sync, the_plat) || ~isfield(mov_shape.(subj).Sync.(the_plat), the_task)
        error('The specified movement does not exist in the data structure.');
    end
    
    movement_data = mov_shape.(subj).Sync.(the_plat).(the_task);
    
    % Extract movement data
    x = movement_data.ResampledMovements{movement_index};
    v = [0, diff(x)];
    
    % Extract phase information
    ext_cells = movement_data.ExtensionCells{movement_index};
    flex_cells = movement_data.FlexionCells{movement_index};
    dwell_cells = movement_data.DwellingCells{movement_index};

    % Create figure
    figure(fig_num); clf;
    hold on;
    
    % LEFT Y-AXIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot x (black)
    h_x = plot(x, 'k', 'LineWidth', 2);
    
    % Plot flexion (blue) and extension (green) phases
    h_ext = [];
    for i = 1:length(ext_cells)
        idx = ext_cells{i};
        h_ext = plot(idx, x(idx), 'g', 'LineWidth', 4);
    end
    
    h_flex = [];
    for i = 1:length(flex_cells)
        idx = flex_cells{i};
        h_flex = plot(idx, x(idx), 'b', 'LineWidth', 4);
    end

    % Indicate dwelling phases with fill
    h_dwell = [];
    for i = 1:length(dwell_cells)
        idx = dwell_cells{i};
        h_dwell = fill([idx(1) idx(1) idx(end) idx(end)], [0 1 1 0], 'y', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
    ylabel('Signal (u.a.)');

    xlim([1 100])

    % RIGHT Y-AXIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    yyaxis right
    h_v = plot(v, 'r', 'LineWidth', 2);
    
    % Set the secondary axis color to red
    ax = gca;
    ax.YAxis(2).Color = 'r';
    
    % Plot horizontal line for v = 0 and epsilon region
    yline(0, '--k');
    % Epsilon for extension
    h_immobile = fill([1:length(v), fliplr(1:length(v))], [epsi_immobile*ones(1,length(v)), -epsi_immobile*ones(1,length(v))], ...
        'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    % Epsilong for flexion (= 3*epsilon for extension)
    h_immobile = fill([1:length(v), fliplr(1:length(v))], [epsi_immobile*3*ones(1,length(v)), -epsi_immobile*3*ones(1,length(v))], ...
        'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    % Epsilon for dwelling
    h_dwell_threshold = fill([1:length(v), fliplr(1:length(v))], [epsi_dwell*ones(1,length(v)), -epsi_dwell*ones(1,length(v))], ...
        'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

    
    % Labels and title
    xlabel('Time (u.a.)');
    yyaxis right
    ylabel('Velocity (u.a.)');
    title(sprintf('%s %s %i %0.1f Hz movement %i', subj, task, task_number, 1+(plat-1)*0.3,  movement_index));
    
    % Add legend
    legend_entries = {'Movement', 'Velocity'};
    legend_handles = [h_x, h_v];
    
    if ~isempty(h_ext)
        legend_entries{end+1} = 'Extension';
        legend_handles(end+1) = h_ext;
    end
    
    if ~isempty(h_flex)
        legend_entries{end+1} = 'Flexion';
        legend_handles(end+1) = h_flex;
    end
    
    if ~isempty(h_dwell)
        legend_entries{end+1} = 'Dwelling';
        legend_handles(end+1) = h_dwell;
    end
    
    legend_entries{end+1} = 'Immobility Threshold';
    legend_handles(end+1) = h_immobile;
    
    legend_entries{end+1} = 'Dwelling Threshold';
    legend_handles(end+1) = h_dwell_threshold;
    
    legend(legend_handles, legend_entries, 'Location', 'southwest', 'NumColumns', 2);
    set(gca,'FontSize', 20)
    hold off;
end

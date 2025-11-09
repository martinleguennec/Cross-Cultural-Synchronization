SAMP_FREQ_STIM = 5000;
SAMP_FREQ_MOV = 500;

participant = "IN01";
task = "sync";
trial = 3;

file_path = fullfile(DAT_PATH, "XP_Indian", participant, sprintf("%s_%s_%i.txt", participant, task, trial));

[stim_signal, mov] = read_file(file_path, SAMP_FREQ_MOV);
[stim, stim_plat_indices, num_plat] = create_stim_indexes(stim_signal, SAMP_FREQ_STIM, participant, task);
[peaks, relphases, relphases_unwrap] = compute_relphase(mov, participant, task, trial, stim_plat_indices, stim, SAMP_FREQ_MOV);

figure(1); clf;
plot(mov(:,2), mov(:,1))

for plat_idx = 1:num_plat
    % Calculate plateau frequency and period
    plat_freq = 1 + (plat_idx-1) * 0.3;
    plat_period = 1 / plat_freq * 1000;
    
    % Determine start and end of the plateau
    [plat_beg, plat_end] = determine_plat_bounds(plat_idx, stim, stim_plat_indices, num_plat, plat_period);
    
    % Get indices and data for the current plateau
    plat_stim = stim(stim_plat_indices(plat_idx, 1) : stim_plat_indices(plat_idx, 2));
    plat_movement = mov((mov(:,2) >= plat_beg) & (mov(:,2) <= plat_end), :);
    plat_peaks = peaks((peaks(:,2) >= plat_beg) & (peaks(:,2) <= plat_end), :);
    plat_relphase = relphases((relphases(:,2) >= plat_beg) & (relphases(:,2) <= plat_end), :);
    plat_relphase_unwrap = relphases_unwrap((relphases_unwrap(:,2) >= plat_beg) & (relphases_unwrap(:,2) <= plat_end), :);
    
    plat_DT = dwell_time(plat_relphase_unwrap(4:end, 1), 0.2);


    if plat_idx == 2

        % Compute the difference of the phase oscillation
        diff_phase_rel = diff(plat_relphase_unwrap(:,1));
        
        % Apply median filter twice to remove peaks in the derivative
        diff_phase_rel = medfilt1(medfilt1(diff_phase_rel, 3), 3);
        
        % Filter parameters for moving average smoothing
        a = 1;
        b = [1/4 1/4 1/4 1/4];
        aver_diff = filter(b, a, diff_phase_rel);


        subplot(3, 2, 1)
        hold on
        xline(plat_stim, 'b', "LineWidth", 1.5)
        plot(plat_movement(:, 2), 100 - plat_movement(:, 1), "k", 'LineWidth', 2)
        plot(plat_peaks(:,2), 100 - plat_peaks(:,1), "ro", "MarkerFaceColor", "r", "MarkerSize", 8)
        xlim([plat_peaks(4,2) - 0.3, plat_peaks(end,2) + 0.3])
        xticks([])
        yticks([10, 90])
        yticklabels(["Flex.", "Ext."])
        hold off
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        title("Synchronized plateau", 'FontSize', 14)
        ylabel('Movement (a. u.)', 'FontSize', 14)

        subplot(3, 2, 3)
        hold on
        yline(0, "--", "LineWidth", 1.2)
        plot(plat_relphase(:,2), plat_relphase(:, 1), "k-o", "LineWidth", 2, "MarkerFaceColor", "k")
        hold off
        ylim([-pi, pi])
        xlim([plat_peaks(4,2) - 0.3, plat_peaks(end,2) + 0.3])
        yticks(-pi : pi/4 : pi)
        yticklabels(["-\pi", "", "-\pi/2", "", "0", "", "\pi/2", "", "\pi"])
        xticks([])
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('Relative phase \phi (rad)', 'FontSize', 14)

        goods = abs(aver_diff) < 0.2;
        bads = abs(aver_diff) >= 0.2;
        dt_t = plat_relphase(2:end, 2);
        subplot(3, 2, 5)
        hold on
        yregion(-0.2, 0.2)
        yline(0, "--", "LineWidth", 1.2)
        plot(dt_t(goods, 1), aver_diff(goods), "o", "MarkerFaceColor", [0.4660, 0.6740, 0.1880], "MarkerEdgeColor", [0.4660, 0.6740, 0.1880], "MarkerSize", 8)
        plot(dt_t(bads, 1), aver_diff(bads), "o", "MarkerFaceColor", [0.6350, 0.0780, 0.1840], "MarkerEdgeColor", [0.6350, 0.0780, 0.1840], "MarkerSize", 8)
        text(29, -0.5, sprintf('%i%s below threshold', plat_DT, "%"), 'FontSize', 10, 'FontName', 'Times New Roman')
        xlim([plat_peaks(4,2) - 0.3, plat_peaks(end,2) + 0.3])
        yticks(-0.8:0.2:0.8)
        ylim([-0.8, 0.8])
        hold off
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('Smoothed d\phi/dt (rad/s)', 'FontSize', 14)
        
    end


    if plat_idx == 17

        % Compute the difference of the phase oscillation
        diff_phase_rel = diff(plat_relphase_unwrap(:,1));
        
        % Apply median filter twice to remove peaks in the derivative
        diff_phase_rel = medfilt1(medfilt1(diff_phase_rel, 3), 3);
        
        % Filter parameters for moving average smoothing
        a = 1;
        b = [1/4 1/4 1/4 1/4];
        aver_diff = filter(b, a, diff_phase_rel);


        subplot(3, 2, 2)
        hold on
        h_stim = xline(plat_stim, 'b', "LineWidth", 1.5);
        h_mov = plot(plat_movement(:, 2), 100 - plat_movement(:, 1), "k", 'LineWidth', 2);
        h_peak = plot(plat_peaks(:,2), 100 - plat_peaks(:,1), "ro", "MarkerFaceColor", "r", "MarkerSize", 8);
        xlim([plat_peaks(5,2) - 0.3, plat_peaks(end-1,2) + 0.3])
        xticks([])
        ylim([0, 100])
        yticks([10, 90])
        yticklabels(["Flex.", "Ext."])
        hold off
        legend([h_stim(1), h_mov, h_peak(1)], "Stimuli", "Movement", "Peaks")
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('Movement (a.u.)', 'FontSize', 14)
        title("Unsynchronized plateau", 'FontSize', 14)

        subplot(3, 2, 4)
        hold on
        yline(0, "--", "LineWidth", 1.2)
        plot(plat_relphase(:,2), plat_relphase(:, 1), "k-o", "LineWidth", 2, "MarkerFaceColor", "k")
        hold off
        ylim([-pi, pi])
        xlim([plat_peaks(5,2) - 0.3, plat_peaks(end-1,2) + 0.3])
        yticks(-pi : pi/4 : pi)
        yticklabels(["-\pi", "", "-\pi/2", "", "0", "", "\pi/2", "", "\pi"])
        xticks([])
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('Relative phase \phi (rad)', 'FontSize', 14)

        goods = abs(aver_diff) < 0.2;
        bads = abs(aver_diff) >= 0.2;
        dt_t = plat_relphase(2:end, 2);
        subplot(3, 2, 6)
        hold on
      
        plot(dt_t(goods, 1), aver_diff(goods), "o", "MarkerFaceColor", [0.4660, 0.6740, 0.1880], "MarkerEdgeColor", [0.4660, 0.6740, 0.1880], "MarkerSize", 8)
        plot(dt_t(bads, 1), aver_diff(bads), "o", "MarkerFaceColor", [0.8500, 0.3250, 0.0980], "MarkerEdgeColor", [0.8500, 0.3250, 0.0980], "MarkerSize", 8)
        yregion(-0.2, 0.2)
        text(105, -0.5, sprintf('%i%s below threshold', plat_DT, "%"), 'FontSize', 12, 'FontName', 'Times New Roman')
        yline(0, "--", "LineWidth", 1.2)
        xlim([plat_peaks(5,2) - 0.3, plat_peaks(end-1,2) + 0.3])
        yticks(-0.8:0.2:0.8)
        xticks(100:0.5:110)
        ylim([-0.8, 0.8])
        hold off
        legend("d\phi/dt < threshold", "d\phi/dt \geq threshold", 'Location', 'southeast')
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('Smoothed d\phi/dt (rad/s)', 'FontSize', 14)
    end
end
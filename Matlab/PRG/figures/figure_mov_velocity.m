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

n_plat = 5;

relphases_slips = relphase_slips(relphases);

subplot(3, n_plat, 2*n_plat+1:3*n_plat)
hold on
yline(0, "--", "LineWidth", 1.5)
plot(relphases_slips(:,2), relphases_slips(:,1), "k-o", "MarkerSize", 2, "MarkerFaceColor", "k", "LineWidth", 2)
xline(stim(stim_plat_indices(:,2)), "b--", "LineWidth", 2)
hold off
ylim([-pi, pi])
yticks(-pi:pi/2:pi)
yticklabels(["-\pi", "-\pi/2", "0", "\pi/2", "\pi"])

for plat_idx = 1:n_plat
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

    
    subplot(3, n_plat, plat_idx)
    hold on
    plot(plat_movement(:, 2), plat_movement(:, 1), "k", "LineWidth", 2)
    plot(plat_peaks(:, 2), plat_peaks(:, 1), "ro", "MarkerFaceColor", "r")
    xline(plat_stim, "b", "LineWidth", 1.5)
    xlim([plat_beg + (plat_end - plat_beg) / 4, plat_beg + 3*(plat_end - plat_beg) / 4])
    
    mov_norm = plat_movement(:,1);
    mov_norm = (mov_norm - min(mov_norm)) / (max(mov_norm) - min(mov_norm));
    plat_velocity = diff(mov_norm);
    mov_norm = mov_norm(2:end);

    stim_idx = ones(size(plat_stim));
    for i_stim = 1:numel(plat_stim)
        stim_idx(i_stim) = find(plat_movement(:,2) >= plat_stim(i_stim), 1);
    end

    subplot(3, n_plat, n_plat + plat_idx)
    hold on
    plot(mov_norm, plat_velocity, "LineWidth", 2, "Color",   [0,0,0,0.2])
    plot(mov_norm(stim_idx), plat_velocity(stim_idx), "ro", "MarkerFaceColor", "r")
    hold off
    yline(0, "k--", "LineWidth", 1.5)
end
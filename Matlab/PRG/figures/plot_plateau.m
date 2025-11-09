function plot_plateau(plat_idx, stim, movement, peaks, relphase, relphase_unwraped, subj, task, task_number, plat_beg, plat_end, freq, DT)
% GENERATE_PLOT Generates plots for each plateau of each task for each participant.
%
% INPUTS:
%   plat_idx - Integer, index of the current plateau.
%   plat_stim - Array, stimulus data.
%   plat_movement - Array, processed movement data with added time vector.
%   plat_peaks - Array, identified peaks in the movement data.
%   plat_relphase - Array, wrapped relative phase values.
%   subj - String, the subject identifier.
%   task - String, the task identifier.
%   task_number - Integer, the task number.
%   group - String, name of the group.
%   plat_beg - Double, beginning time of the plateau.
%   plat_end - Double, end time of the plateau.
%   plat_freq - Double, frequency of the plateau.
%   plat_DT - Double, dwell time for the plateau.
%   mov_shape - Struct, structure containing movement data.
%
% This function generates plots for each plateau of each task for each participant
% and saves them to the results directory.

% Calculate mean length and theta for the polar plot
if length(relphase(:,1)) > 3
    r = mean(exp(sqrt(-1)*relphase(4:end,1)));
    theta = angle(r);
    mean_length = abs(r);
else
    theta = 0;
    mean_length = 0;
end

% Create the figure
figure;

% Plot the movement data
subplot(2, 3, 1:2)
hold on
plot(movement(:,2), movement(:,1), "k", "LineWidth", 2)
plot(peaks(:,2), peaks(:,1), ".r", "Color", "#D95319", "MarkerSize", 20)
xline(stim, "Color" ,"#0072BD", "LineWidth", 2)
xlim([plat_beg plat_end]); 
xlabel("", 'FontSize', 10);
ylabel("Goniometer (mV)", 'FontSize', 10);
grid on

% Plot the relative phase
phi_slips = relphase_slips(relphase_unwraped);
subplot(2, 3, 4:5)
hold on
yyaxis left
yline(0, "LineStyle", "--", "LineWidth", 3)
plot(phi_slips(:,2), phi_slips(:,1), "k", "LineWidth", 2)
plot(relphase(:,2), relphase(:,1), "k.", "MarkerSize", 20)
xlim([plat_beg plat_end]); 
ylim([-pi pi])
ylabel("\phi (rad.)", 'FontSize', 10);
set(gca, 'YTick', -pi:pi/2:pi, 'YTickLabel', {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'})

% Adjust y-axis for different frequencies
yyaxis right
if freq == 1
    set(gca, 'YTick', -450:150:450)
elseif freq <= 1.6
    set(gca, 'YTick', -300:150:300)
elseif freq <= 2.5
    set(gca, 'YTick', -200:100:200)
elseif freq <= 4.9
    set(gca, 'YTick', -150:50:150)
elseif freq < 6.7
    set(gca, 'YTick', -100:25:100)
else
    set(gca, 'YTick', -80:20:80)
end
yline(150, "r--", "LineWidth", 1.5)
yline(-150, "r--", "LineWidth", 1.5)
grid on

% Polar plot of relative phase
subplot(2, 3, 3)
if (length(relphase) > 3)
    polarplot(relphase(4:end,1), 1, "ok", "MarkerFaceColor", "k", "MarkerSize", 8)
    hold on
    polarplot([0 theta], [0 mean_length], "-", "LineWidth", 2)
    ax = gca;
    ax.ThetaAxisUnits = 'radians';
end

% Phase space plot
subplot(2, 3, 6)
temp = [];
for flex = 1:size(stim)
    a = find(movement(:,2) > stim(flex));
    temp(flex) = a(1) - 1;
end
x = zscore(movement(2:end,1));
y = diff(zscore(movement(:,1)));
hold on
xline(0, "k")
yline(0, "k")
plot(x, y)
plot(x(temp), y(temp), ".r", "MarkerSize", 20)
xlabel("x"), ylabel("v")

% Calculate standard deviation of mean length
SD = sqrt(-2*log(mean_length));

% Set title
sgtitle(subj + ", " + task + " " + task_number + ", " + (1 + (plat_idx-1) * 0.3) + ...
    "Hz - DT: " + DT + ", SD: " + SD, "FontSize", 20)

set(gcf, 'WindowState', 'maximized')

end

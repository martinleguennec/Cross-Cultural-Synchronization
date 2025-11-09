function [signal_resampled, new_time] = signalResampling(signal, time, new_sampFreq)

new_time = 0 : 1/new_sampFreq : time(end); 
new_time = new_time(1: end-1)';
signal_resampled = interp1(time, signal, new_time);
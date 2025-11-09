function filtered_signal = NotchFilter(cutoff_freq, sampFreq, q_filter, signal)

notch_frequency = cutoff_freq;
Wo = notch_frequency/(sampFreq/2); BW = Wo / q_filter;
[b,a] = iirnotch(Wo, BW);

filtered_signal= filtfilt(b, a, signal);
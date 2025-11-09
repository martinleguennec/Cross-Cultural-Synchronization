function Phases = relphase(Reference, Target, period)
%RELPHASE Calculate relative phase.
%
% Phases = relphase(Reference, Target, period) calculates
% the relative phase between "Reference" and "Target". In formula,
% if T_j is between references R_i and R_i+1:
% relphase = 2*pi*(R_i - T_j)/(R_i+1 - R_i)
%
% The optional argument "period" allows the user the specify the
% period of the data if this is know beforehand. Specifying "period"
% assures that all extrema in Target are used (by extending Reference).
% Note that the relative phase of any "Target" that is not in the
% range of "Reference" is not calculated, unless period is specified.
%
% The time-values of "Target" are assigned to the "Phases".
%
% Input:  Reference   N by 2+ first col: reference extremum, sec col: time
%         Target      M by 2+ first col: target extremum, sec col: time
%  (opt)  period      1 by 1  period of "Reference" > 0
% Output: Phases      K by 2  first col: phase, second col: time

% This routine is part of "RelPhase.Box", a toolbox for relative
% phase analysis of oscillatory systems. See the manual or README
% file for conditions under which this software may be used.
%
% Version 0.97, 26 january 1998 by Tjeerd Dijkstra.
% Tested with MATLAB 5.1 on a PowerCenter 132 under System 7.5.5

warning_crit = 0.05;

if (nargin ~= 2) & (nargin ~= 3),
	fprintf('Error in relphase: Number of arguments is %d, ', nargin);
	fprintf('should be 2 or 3\n'); Phases = []; return;
end

if isempty(Reference) | isempty(Target),
	fprintf('Warning in relphase: Reference or Target is empty\n');
	Phases = []; return;
end

[Nr, Mr] = size(Reference);
if Mr < 2,
	fprintf('Error in relphase: Reference has %d columns, should be ', Mr);
	fprintf('at least 2\n'); Phases = []; return;
end
ref = Reference(:, 2);
index = find(diff(ref) <= 0);
if length(index) > 0,
	fprintf('Error in relphase: time of Reference not strictly increasing\n');
	Phases = []; return;
end

[Nt, Mt] = size(Target);
if Mt < 2,
	fprintf('Error in relphase: Target has %d columns, should be ', Mt);
	fprintf('at least 2\n'); Phases = []; return;
end
tar = Target(:, 2);
index = find(diff(tar) <= 0);
if length(index) > 0,
	fprintf('Error in relphase: time of Target not strictly increasing\n');
	Phases = []; return;
end

if nargin < 3,
	if (min(tar) > max(ref)) | (max(tar) < min(ref)),
		fprintf('Error in relphase: Extrema of target and reference do ');
		fprintf('not overlap in time\n'); Phases = []; return;
	end
	if Nr < 2,
		fprintf('Error in relphase: Reference has only one extremum\n');
		Phases = []; return;
	end

	cycle_len = diff(ref);
else
	if period <= 0,
		fprintf('Error in relphase: Period should be greater than 0\n');
		Phases = []; return;
	end

	extra_cycles = ceil((min(ref) - min(tar))/period);
	if extra_cycles > 0,
		ref = [ref(1) - period*[extra_cycles:-1:1]'; ref];
	end
	extra_cycles = ceil((max(tar) - max(ref))/period);
	if extra_cycles > 0,
		ref = [ref; ref(length(ref)) + period*[1:extra_cycles]' ];
	end
	[Nr, Mr] = size(ref);

	cycle_len = period*ones(Nr-1, 1);
	if any(abs(diff(ref) - cycle_len) ./ cycle_len > warning_crit),
% 		fprintf('Warning in relphase: period differs more than ');
% 		fprintf('%4.3f from diff(Reference)\n', warning_crit);
% 		fprintf('Are you shure the period you specified for relphase ');
% 		fprintf('is correct?\n');
	end
end

% When the first target falls before the first reference time, we switch
% reference and target, i.e. we take the time of occurence of the reference
% time between two target times.
% We can assume overlap in target and reference, since we tested in line 66.
index = find(tar < ref(1));
len = length(index);
if len > 0,
	Phases(1:len, :) = [2*pi*((ref(1) - tar(index))/...
					(tar(index+1) - tar(index)) + [-len:-1:-1]'), tar(index)];
end
l = 1 + len; wrap = 0;

% l = 1; wrap = 0;
for i = 1:Nr-1,
	index = find((tar >= ref(i)) & (tar < ref(i+1)));
	len = length(index);
	if len > 0,
		Phases(l:l+len-1, :) = [2*pi*((ref(i) - tar(index))/...
						cycle_len(i) + [wrap:wrap+len-1]'), tar(index)];
	end
	l = l + len; wrap = wrap + len - 1;
end

% A sublety for the last reference cycle.
index = find(tar == ref(Nr));
len = length(index);
if len > 0,
	Phases(l:l+len-1, :) = [2*pi*[wrap:wrap+len-1]', tar(index)];
end

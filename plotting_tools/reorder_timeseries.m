function [T,Y] = reorder_timeseries(T,Y,tmin,period)

if nargin >4
    period = period;
else
    period = 24; %assume default 24hr period
end

T = [T(1:end-1)-period;T];
Y = [Y(1:end-1,:);Y];
tmax = tmin+period;
Y_at_tmin = interp1(T,Y,tmin);
Y_at_tmax = interp1(T,Y,tmax);

idx_start = find(T>tmin,1);
idx_end = (find(T>tmax,1)-1);
Y = [Y_at_tmin;Y(idx_start:idx_end,:);Y_at_tmax];
T = [tmin;T(idx_start:idx_end,:);tmax];
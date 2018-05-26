function [T,Y] = simulate_model(options)

option_fieldnames = {'photoperiod','genotype','temperature','Poverride'};
defaults = {12,{''},22,struct()};
input_option_fieldnames = fieldnames(options);
nIOF = length(input_option_fieldnames);
nOF = length(option_fieldnames);

% Check that all input option fieldnames are valid
for i = 1:nIOF
    if ~ ismember(input_option_fieldnames{i},option_fieldnames)
        error('Simulation option struct contains unrecognised fieldnames')
    end
end

% Set defaults if an option was not set
for i = 1:nOF
    if ~ ismember(option_fieldnames{i},input_option_fieldnames)
        %this option has not been set by user: load default
        options.(option_fieldnames{i}) = defaults{i};
    else
        %leave this option alone alone
    end
end


% Load light conditions into 'c' for common light function
c.period = 24;
c.phase = 0;
c.dawn = 0;
c.photoperiod = options.photoperiod;

% Define timepoints at which simulation output should be provided
output_timepoints = [0:0.1:c.period];

% Include model folders in path
addpath('P2011_model')
addpath('PIF_CO_FT_model')

parameters.clock = load_P2011_parameters(options.genotype);
clock_dynamics = @P2011_dynamics;
clock_dynamics_wrapper = @wrap_P2011_model_dynamics;

% Initialise clock model
y0=[1.0151 0.956 0.0755 0.0041 0.506 0.0977 0.0238 0.0731 0.0697 0.0196 0.0435 0.2505 0.0709 0.1017 0.0658 0.4016 0.1167 0.1012 0.207 0.0788 0.3102 0.0553 0.2991 0.1503 0.0286 0.65 0.2566 0.1012 0.576 0.3269];
[T,Y] = ode15s(@(t,y) clock_dynamics(t,y,parameters.clock,c),[0 6*c.period],y0);
y0 = Y(end,:)';

% Simulate for one day
[Tc,Yc] = ode15s(@(t,y) clock_dynamics(t,y,parameters.clock,c),[0 c.period],y0);
% Convert dynamics into input struct for PIF_CO_FT model
u = clock_dynamics_wrapper(Tc,Yc,parameters.clock);

% Load PIF_CO_FT parameters
parameters.PIF_CO_FT = load_PIF_CO_FT_parameters(options.genotype,options.temperature);

% Override any parameters that have alternative values given by input
% options
Poverride_names = fieldnames(options.Poverride);
nPO = length(Poverride_names);
for i = 1:nPO
    Pname = Poverride_names{i};
    parameters.PIF_CO_FT.(Pname) = options.Poverride.(Pname);
end

% Run CO-PIF-FT model
% Initialise clock model
y0=ones(1,18);
[T,Y] = ode15s(@(t,y) PIF_CO_FT_dynamics(t,y,parameters.PIF_CO_FT,u,c),[0 5*c.period],y0);
y0 = Y(end,:)';
% Simulate for one day
[T1,Y1] = ode15s(@(t,y) PIF_CO_FT_dynamics(t,y,parameters.PIF_CO_FT,u,c),output_timepoints,y0);

u = struct();
u.T = T1;
u.PIF = Y1(:,3);
u.INT = Y1(:,6);

% Load PhyA model
parameters.PHYA = load_PHYA_parameters(options.genotype);

% Run phyA model
y0=ones(1,4);
[T,Y] = ode15s(@(t,y) phyA_model_dynamics(t,y,parameters.PHYA,u,c),[0 5*c.period],y0);
y0 = Y(end,:)';
[T2,Y2] = ode15s(@(t,y) phyA_model_dynamics(t,y,parameters.PHYA,u,c),output_timepoints,y0);

T = output_timepoints';
Y = [Y1,Y2];
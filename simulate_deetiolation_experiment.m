options.genotype = {''};
options.temperature = 22;
options.Poverride.n10 = 0.1; %PHYA basal transcription

% Load light conditions into 'c' for common light function
cDD.period = 24;
cDD.phase = 0;
cDD.dawn = 0;
cDD.photoperiod = 0;

cLL.period = 24;
cLL.phase = 0;
cLL.dawn = 0;
cLL.photoperiod = 24;

c1 = cLL;

genotypes = {{''},{''},{'pif4','pif5'},{'pif4','pif5'}};
initial_conditions = {cDD,cLL,cDD,cLL};
legend_text = {'WT, D-->R','WT, cR','\it{pifQ}, D-->R','{\itpifQ}, cR'};
sim_id = {'WT_DR','WT_cR','pifQ_DR','pifQ_cR'};

figure('Position',[100,100,400,200])
hold on

for i = 1:4
    
    options.genotype = genotypes{i};
    c0 = initial_conditions{i};

    % Define timepoints at which simulation output should be provided
    output_timepoints = [0:0.1:c1.period];

    % Include model folders in path
    addpath('P2011_model')
    addpath('PIF_CO_FT_model')

    parameters.clock = load_P2011_parameters(options.genotype);
    clock_dynamics = @P2011_dynamics;
    clock_dynamics_wrapper = @wrap_P2011_model_dynamics;

    % Initialise clock model
    y0=[1.0151 0.956 0.0755 0.0041 0.506 0.0977 0.0238 0.0731 0.0697 0.0196 0.0435 0.2505 0.0709 0.1017 0.0658 0.4016 0.1167 0.1012 0.207 0.0788 0.3102 0.0553 0.2991 0.1503 0.0286 0.65 0.2566 0.1012 0.576 0.3269];
    [Tc,Yc] = ode15s(@(t,y) clock_dynamics(t,y,parameters.clock,c0),[0 6*c0.period],y0);
    u0 = clock_dynamics_wrapper(Tc,Yc,parameters.clock);
    y0 = Yc(end,:)';

    % Simulate for one day
    [Tc,Yc] = ode15s(@(t,y) clock_dynamics(t,y,parameters.clock,c1),[0 c1.period],y0);
    % Convert dynamics into input struct for PIF_CO_FT model
    u1 = clock_dynamics_wrapper(Tc,Yc,parameters.clock);

    % Load PIF_CO_FT parameters
    parameters.PIF_CO_FT = load_PIF_CO_FT_parameters(options.genotype,options.temperature);
    % Override any parameters that have alternative values given by input
    % options
    Poverride_names = fieldnames(options.Poverride);
    nPO = length(Poverride_names);
    for j = 1:nPO
        Pname = Poverride_names{j};
        parameters.PIF_CO_FT.(Pname) = options.Poverride.(Pname);
    end


    % Run CO-PIF-FT model
    % Initialise clock model
    y0=ones(1,18);
    [T,Y] = ode15s(@(t,y) PIF_CO_FT_dynamics(t,y,parameters.PIF_CO_FT,u0,c0),[0 5*c0.period],y0);
    y0 = Y(end,:)';
    u0 = struct();
    u0.T = T;
    u0.PIF = Y(:,3);
    u0.INT = Y(:,6);

    % Simulate for one day
    [T1,Y1] = ode15s(@(t,y) PIF_CO_FT_dynamics(t,y,parameters.PIF_CO_FT,u1,c1),output_timepoints,y0);

    u1 = struct();
    u1.T = T1;
    u1.PIF = Y1(:,3);
    u1.INT = Y1(:,6);

    % Load PhyA model
    parameters.PHYA = load_PHYA_parameters(options.genotype);

    % Run phyA model
    y0=ones(1,4);
    [T,Y] = ode15s(@(t,y) phyA_model_dynamics(t,y,parameters.PHYA,u0,c0),[0 5*c0.period],y0);
    y0 = Y(end,:)';
    [T2,Y2] = ode15s(@(t,y) phyA_model_dynamics(t,y,parameters.PHYA,u1,c1),output_timepoints,y0);

    T = output_timepoints';
    Y = [Y1,Y2];
    
    file_data = load('varnames','varnames');
    varnames = file_data.varnames;
    
    sim_data = array2table([T,Y],'VariableNames',varnames);
    writetable(sim_data,['sim_data/leivar2009_',sim_id{i},'_sim_data'])
    plot(T,Y(:,21))
%     display(legend_text{i})
%     'Value at T = 0:'
%     display(Y(1,21))
%     'Value at T = 1:'
%     display(interp1q(T,Y(:,21),1))
%     plot(1,interp1q(T,Y(:,21),1),'o')
end

box on
ax = gca;
ax.XTick=[0,8,16,24];
xlim([0,24]);
xlabel('Time (h)');
ylabel('Expression (a.u.)');
legend(legend_text)


h = gcf;
h.Units='Inches';
screenposition = h.Position;
% h.PaperPosition=[0 0 screenposition(3:4)];
h.PaperPositionMode = 'auto';
h.PaperUnits='Inches';
h.PaperSize=[screenposition(3:4)];
input('Script will now save figure.\n Press RETURN to continue.', 's');
saveas(h,['figures/',mfilename()],'svg')

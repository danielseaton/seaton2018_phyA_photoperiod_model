%get phyA mRNA dynamics in different conditions
addpath('plotting_tools')
% load('phyA_signalling_DIURNAL_examples')

% photoperiods = {8,16,12,12,8,8};
% genotypes = {{''},{''},{''},{'lux'},{''},{'CCA1ox'}};


photoperiods = {8,16,8,16};
genotypes = {{''},{''},{'pif4','pif5'},{'pif4','pif5'}};
legend_text = {'Short days', 'Long days'};
condition_names = {'WT_SD','WT_LD','pif4pif5_SD','pif4pif5_LD'};
colours = {'b','r'};
 
% photoperiods = {8,8};
% genotypes = {{''},{'CCA1ox'}};
% exp_data_condition_indices = [3,4];
% condition_names = {'LER_SD','lhyox_SD'};
% colours = {'k',[0,0.75,0]};
% legend_text = {'WT', 'LHYox'};
% condition_name = 'LHYox';

% photoperiods = {12,12};
% genotypes = {{''},{'lux'}};
% exp_data_condition_indices = [1,2];
% condition_names = {'COL_LDHH','lux-2_LDHH'};
% colours = {'k',[0.65,0,0.65]};
% legend_text = {'WT','lux'};
% condition_name = 'lux';


% photoperiods = {8,8};
% genotypes = {{''},{'pif4','pif5'}};
% legend_text = {'WT','pif4pif5'};
% condition_names = {'WT_SD','pif4pif5_SD'};
% colours = {'b','r'};
% condition_name = 'pif4pif5_SD';


% photoperiods = {8,8,8};
% genotypes = {{''},{'YHB'},{'phyA','phyB'}};
% legend_text = {'WT, SD','YHB, SD','phyABCDE, SD'};
% condition_names = {'WT_SD','YHB_SD','phyABCDE_SD'};
% colours = {'b','r','g'};
% condition_name = 'YHB_phy_SD';




Sidx = 22;


nC = length(photoperiods);

if exist([condition_name,'.mat'])
%     load([condition_name,'.mat'],'T','Y','photoperiods','genotypes',...
%         'exp_data_condition_indices','colours','legend_text',...
%         'condition_name')
else
    T = cell(nC,1);
    Y = cell(nC,1);
    for i = 1:nC
        condition = condition_names{i};
        options = struct();
        options.photoperiod = photoperiods{i};
        options.genotype = genotypes{i};
        [Ttemp,Ytemp] = simulate_model(options);
        T{i} = Ttemp;
        %Only output a few species of interest
%         Y{i} = Ytemp(:,[7,19,20,21]);
        Y{i} = Ytemp;
        file_data = load('varnames','varnames');
        varnames = file_data.varnames;
    
        sim_data = array2table([Ttemp,Ytemp],'VariableNames',varnames);
        writetable(sim_data,['sim_data/',condition,'_sim_data'])
    end
%     save(condition_name,'T','Y','photoperiods','genotypes',...
%         'exp_data_condition_indices','colours','legend_text',...
%         'condition_name')
end


LW = 1.4;
FS = 14;

figure('Position',[50,50,600,700]);

subplot(1,1,1)

for i = 1:nC
    hold on
    box on
    plot([T{i};T{i}+24],[Y{i}(:,Sidx);Y{i}(:,Sidx)],'-','Color',colours{i},'LineWidth',LW)
end

h_legend = legend(legend_text);
set(h_legend,'FontSize',FS+2);
xlabel('Time (h)','FontSize',FS)
xlim([0,44])
set(gca,'XTick',[0:6:48]);
ylabel('Relative Expression','FontSize',FS)
set(gcf,'Color','w')


% row_indices = (exp_data_species_index-1)*7+exp_data_condition_indices;
% 
% MS = 6;
% 
% % figure('Position',[50,50,600,350]);
% subplot(2,1,2)
% 
% exp_data_timepoints = [0:4:44];
% for i = 1:nC
%     hold on
%     box on
%     plot(exp_data_timepoints,expression_data(row_indices(i),:),'s-',...
%         'Color',colours{i},'MarkerSize',MS,'MarkerFaceColor',colours{i});
% end
% h_legend = legend(legend_text);
% set(h_legend,'FontSize',FS+2);
% xlabel('Time (h)','FontSize',FS)
% xlim([0,44])
% set(gca,'XTick',[0:6:48]);
% ylabel('Relative Expression','FontSize',FS)
% set(gcf,'Color','w')
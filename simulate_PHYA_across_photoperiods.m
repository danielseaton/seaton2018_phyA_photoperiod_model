photoperiods = 3:19;
% photoperiods = [5,6];
genotype = {''};
Sidx = 7;

nC = length(photoperiods);

T = cell(nC,1);
Y = cell(nC,1);
output_data = zeros(1,nC*2);
data_cols = cell(1,nC*2);
for i = 1:nC
    options = struct();
    options.photoperiod = photoperiods(i);
    options.genotype = genotype;
    [Ttemp,Ytemp] = simulate_model(options);
    EN = interp1(Ttemp,Ytemp(:,Sidx),0);
    ED = interp1(Ttemp,Ytemp(:,Sidx),photoperiods(i));
    data_cols{i*2-1} = ['EN_',num2str(photoperiods(i)),'H'];
    data_cols{i*2} = ['ED_',num2str(photoperiods(i)),'H'];
    output_data(i*2-1:i*2)= [EN,ED];
end


fid = fopen('sim_data/PHYA_photoperiods_sim_data.csv','w');
for i = 1:nC*2-1
    fprintf(fid,'%s\t',data_cols{i});
end
fprintf(fid,'%s\n',data_cols{nC*2});

for i = 1:nC*2-1
    fprintf(fid,'%s\t',output_data(i));
end
fprintf(fid,'%s',output_data(nC*2));
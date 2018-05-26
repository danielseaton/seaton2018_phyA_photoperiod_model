function P = load_PHYA_parameters(genotype)

% For a reasonable fit to microarrays in first attempt
% ksp = 1;
% kdp1 = 0.25;
% kdp2 = 1*kdp1;
% kf1 = 0.01;
% kf2 = 100*kf1;
% kr = 0.3;
% ksx = 0.75;
% ksx0 = 0.24;
% kdx = 0.2;
% Ksx = 0.4;


P = struct();

% P.ksPHYAm1 = 0.1;
% P.ksPHYAm2 = 2.0;
% P.KsPHYAm = 0.7;
% P.kdPHYAm = 0.7;
% P.KINT = 7.5;
% P.ksP = 1;
% P.kdP1 = 0.5;
% P.kdP2 = 5*P.kdP1;
% P.kf1 = 0.01;
% P.kf2 = 100*P.kf1;
% P.kr = 0.3;
% P.ksX1 = 0.04;
% P.ksX2 = 0.24;
% P.kdX = 0.5;
% P.KsX = 0.3;

P.k_s1 = 0.1;
P.k_s2 = 2.0;
P.K_1 = 0.7;
P.k_d1 = 0.7;
P.KINT = 7.5;
P.k_s3 = 1; 
P.k_d2 = 0.5;
P.k_d3 = 5*P.k_d2;
P.k_a1 = 0.01;
P.k_a2 = 100*P.k_a1;
P.k_r = 0.3;
P.k_s4 = 0.04;
P.k_s5 = 0.24;
P.k_d4 = 0.5;
P.K_2 = 0.3;

if ismember('phyA',genotype)
    % No PHYA
    P.ksPHYAm1 = 0;
    P.ksPHYAm2 = 0;
end

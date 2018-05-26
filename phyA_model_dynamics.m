function dydt = phyA_model_dynamics(t,y,P,u,c)
%PHYA_MODEL_DYNAMICS Dynamics of a simple model of phyA signalling in diurnal
%conditions

y = num2cell(y);
[PHYAm,Pr,Pfr,X] = deal(y{:});

% L = c.light_fcn(t,c);
% L = light_conditions(t,c);

t = mod(t, c.period);

LightOffset = 0; %Shifts light function up or down.
twilightPer = 2.05; %The duration of time between value of force in dark and value of force in light.
LightAmp = 1; %The amplitude of the light wave.

if (c.photoperiod == 0)
    L = 0;
elseif (c.photoperiod == c.period)
    L = 1;
else
    L = LightOffset + 0.5*LightAmp*(1 + tanh((c.period/twilightPer)*((t-c.dawn)/c.period - floor(floor(t-c.dawn)/c.period)))) - 0.5*LightAmp*(1 + tanh((c.period/twilightPer)*((t-c.dawn)/c.period - floor(floor(t-c.dawn)/c.period)) - c.photoperiod/twilightPer)) + 0.5*LightAmp*(1 + tanh((c.period/twilightPer)*((t-c.dawn)/c.period - floor(floor(t-c.dawn)/c.period)) - c.period/twilightPer));
end




INT = interp1(u.T,u.INT,mod(t,c.period));
PIF = interp1(u.T,u.PIF,mod(t,c.period));
PIFact = PIF^2/(PIF^2+(P.KINT*INT)^2);

% dPHYAmdt = P.ksPHYAm1+P.ksPHYAm2*PIFact^2/(P.KsPHYAm^2+PIFact^2) - P.kdPHYAm*PHYAm;
% dPrdt = P.ksP*PHYAm + P.kr*Pfr - (P.kdP1+(P.kf1+P.kf2*L))*Pr;
% dPfrdt = (P.kf1+P.kf2*L)*Pr - (P.kdP2+P.kr)*Pfr;
% dXdt = P.ksX1 + P.ksX2*Pfr^2/(P.KsX^2+Pfr^2) - P.kdX*X;

dPHYAmdt = P.k_s1 +P.k_s2*PIFact^2/(P.K_1^2+PIFact^2) - P.k_d1*PHYAm;
dPrdt = P.k_s3*PHYAm + P.k_r*Pfr - (P.k_d2+P.k_a1+P.k_a2*L)*Pr;
dPfrdt = (P.k_a1+P.k_a2*L)*Pr - (P.k_d3+P.k_r)*Pfr;
dXdt = P.k_s4 + P.k_s5*Pfr^2/(P.K_2^2+Pfr^2) - P.k_d4*X;


dydt = [dPHYAmdt
        dPrdt
        dPfrdt
        dXdt];

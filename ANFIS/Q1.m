%% Sistema Nebulosos: TP3 - QUEST�O 1
%Aproxima��o da fun��o seno - ANFIS
%Thiago Mattar e Pedro Soares

% Limpa a �rea de trabalho
clear all; clc;

% Defini��o dos dados
x = (0:0.1:(2*pi))';
y = sin(x);
anfisInputs = [x y];

% Defini��o das configura��es
opt = anfisOptions();
opt.InitialFIS = 3;
opt.EpochNumber = 50;

% Treinamento
fis = anfis(anfisInputs,opt);

%Avalia��o dos dados
anfisOutput = evalfis(x,fis);

%Plot da aproxima��o
figure(1)
plot(x,y,'LineWidth',2); hold on
plot(x,anfisOutput,'r--','LineWidth',2)
title('Aproxima��o de f(x) por Sugeno');
xlim([0 2*pi]); ylim([-1.1 1.1])
legend('Training Data','ANFIS Output','Location','NorthEast')
xlabel('x'); ylabel('y'); grid;

%Plot das fun��es de pertinencia
figure(2)
plotmf(fis,'input',1)
title('Fun��es de pertin�ncia'); grid;

%Print do RMSE
e2 = sum((y - anfisOutput).^2);
disp(['RMSE = ' num2str(e2)]);







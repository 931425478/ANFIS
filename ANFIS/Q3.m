%% Sistema Nebulosos: TP3 - QUEST�O 2
%Sistema de classifica��o
%Thiago Mattar e Pedro Soares

% Limpa a �rea de trabalho
clear all; clc;

% Leitura dos dados
load('C:\Users\Thiago\Documents\Sistemas Nebulosos\TP3\ArquivosTP3\dataset_2d.mat')

% Normaliza��o dos dados
x(:,1) = (x(:,1) - mean(x(:,1)))/(max(x(:,1))-min(x(:,1)));
x(:,2) = (x(:,2) - mean(x(:,2)))/(max(x(:,2))-min(x(:,2)));

% Visualiza��o dos dados
figure(1)
plot(x(y==1,1),x(y==1,2),'r+',...
    x(y==0,1),x(y==0,2),'o');
legend('C1','C2');
xlim([-1 1]); ylim([-1 1]);
xlabel('x1'); ylabel('x2');
title('Distribui��o dos dados normalizados');

% Defini��o de Y
y(y==0) = -1;

%% Definindo treino e teste 
[trainX,trainY,testX,testY] = SplitTrainAndTest(x,y);

%% Defini��o do n� de regras

% Fun��o de parametriza��o
fprintf('\n Parametrizando modelo ... \n');
accuracy = testModel(trainX,trainY,30);

figure(2)
subplot(2,1,1);
plot(accuracy(2:end,1),'LineWidth',2);
title('Avalia��o do n�mero de regras');
xlim([2 29]); xlabel('N� de regras'); ylabel('Acur�cia m�dia'); grid;
subplot(2,1,2);
plot(accuracy(2:end,2),'r','LineWidth',2);
xlim([2 29]); xlabel('N� de regras'); ylabel('Vari�ncia'); grid;



%% Definindo dimens�o final do ploblema
[~,nclus_best] = max(accuracy(:,1)./accuracy(:,2).^2);
fprintf('\n Calculando solu��o final ...');

% Solu��o final
acc_fin = zeros(30,1);
for i = 1:30
    [trainX,trainY,testX,testY] = SplitTrainAndTest(x,y);
    [acc_fin(i),~] = trainAndTestAnfisByFCM(trainX,trainY,nclus_best,testX,testY);  
end

acc_mean = mean(acc_fin);
acc_sd = std(acc_fin);

fprintf('\n\n');
disp('-----------SOLU��O FINAL--------'); 
disp(['N� de regras: ' num2str(nclus_best)]);
disp(['Acur�ria: ' num2str(acc_mean) ' +/- ' num2str(acc_sd)]);


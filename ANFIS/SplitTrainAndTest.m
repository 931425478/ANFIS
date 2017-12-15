function [trainX,trainY,testX,testY] = SplitTrainAndTest(x,y)
% Fun��o de separa��o dos dados em treinamento e teste

    % �ndices
    splitIdx = randperm(length(y));
    trainIdx = splitIdx(1:(0.7*length(splitIdx)));
    testIdx = splitIdx((0.7*length(splitIdx)+1):end);

    % Dados
    trainX = x(trainIdx,:);
    trainY = y(trainIdx,:);
    testX = x(testIdx,:);
    testY = y(testIdx,:);   
    
end

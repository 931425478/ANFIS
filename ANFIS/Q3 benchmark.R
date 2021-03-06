rm(list=ls())
library('mlbench')
library('e1071')
library('caret')
library('clusterSim')
library('DEoptim')
library('rgl')
library('readr')

#Algoritmo Diferencial Evolutivo
diffEvo <- function(FUN,lb,ub,N)
{
  #- FUN = fun��o objetivo a ser otimizada
  #- lb = vetor contendo os limites superiores das vari�veis de decis�o
  #- N = tamanho da popula��o inicial
  
  #-----------------Defini��o dos par�metros
  #Gera��o atual
  g = 1   
  #M�ximo n�mero de gera��es
  gmax = 40
  
  #Probabilidade de recombina��o
  c = 0.7
  #Fator de escala
  f = 0.99
  l = 0
  
  #Dimens�o do problema
  n = length(lb)
  
  #Par�metro de controle
  bestIndTroughTime = list()
  
  #Popula��o inicial
  P = matrix(0,nrow=N,ncol=n)
  for(i in 1:n)
  {
    P[,i]<-runif(n = N,min = lb[i],max = ub[i])
  }
  
  #Matriz de recombina��o
  U = matrix(0,nrow=N,ncol=n)
  
  #Avalia��o das solu��es candidatas
  jP = evalFobj(FUN,P)
  
  #Vetores de controle de popula��o; 
  Jbest = c()
  Jmed = c()
  
  bench = 1
  mov.ind = list()
  
  #------------------LOOP Principal
  while(g<=gmax && (sum(bench)!=0))
  {
    
    #Calcula tempo de itera��o
    t0 = Sys.time()
    
    #Calcula melhores indiv�duos
    Jbest[g]=min(jP)
    Jmed[g]=median(jP)
    
    #Recombina��o dos indiv�duos
    bench = c()
    
    for(i in 1:N)
    {
      r = c(sample(N,3),which.min(jP))
      delta = sample(N,1)
      for(j in 1:n)
      {
        if(runif(1)<=c || j==delta)
        {
          U[i,j] = P[r[1],j] + f*(P[r[2],j]-P[r[3],j]) + l*((P[r[1],j]-P[r[4],j]))
        }else
        {
          U[i,j] = P[i,j]
        }
      }
      
      bench[i] = ((P[r[1],j]-P[r[4],j]))
      mov.ind[[g]] = bench
      
      #Reflex�o para dentro dos limites fact�veis
      for(j in 1:n)
      {
        if(U[i,j]<lb[j])
        {
          U[i,j] = lb[j]
        }else if(U[i,j]>ub[j])
        {
          U[i,j] = ub[j]
        }
      }
      
      #Sele��o dos indiv�duos
      if(FUN(U[i,]) <= FUN(P[i,]))
      {
        P[i,] = U[i,]
      }
    }
    
    #Avalia��o das solu��es candidatas
    jP = evalFobj(FUN,P)
    
    #Printa itera��o e tempo
    print(Sys.time()-t0)
    print(c(g,gmax,Jbest[g]))
    print(P[which.max(jP),])
    
    #Melhor �ndividuo da gera��o
    bestIndTroughTime[[g]] <- P[which.max(jP),]
    
    #Itera��o
    g = g + 1
  }
  
  output = list(Jbest = Jbest,
                Jmed = Jmed,
                best.ind = P[which.min(jP),],
                best.fitness = min(jP),
                POP = P,
                dif.vectors = mov.ind,
                jP = jP,
                bestIndTroughTime = bestIndTroughTime)
  
  return(output)
}

#Avalia��o da fun��o objetivo p/ toda popula��o
evalFobj <- function(FUN,P)
{
  N = nrow(P)
  n = ncol(P)
  
  output = c()
  for(i in 1:N)
  {
    output[i] = FUN(P[i,])
  }
  
  return(output)
}

#Fun��o Objetivo
#OBS: RETORNA -ACC PARA REALIZAR A OTIMIZA��O
trainAndTestSVM.OBJ <- function(x)
{
  
  #Defini��o dos par�metros
  C = 10^x[1]
  g = 10^x[2]
  
  #Treino e teste
  splitIndex = createDataPartition(Y,times=1,p=0.7,list=FALSE)
  trainX = X[splitIndex,]
  testX = X[-splitIndex,]
  trainY = Y[splitIndex]
  testY = Y[-splitIndex]
  
  #Treina e constr�i o modelo
  svm.model = svm(trainY ~. , data = trainX,
                  cost=C,gamma=g)
  
  #Prediz a classe das amostras de teste
  Yhat = as.numeric(predict(svm.model,testX))
  
  #Aplica o limiar
  Yhat[Yhat<0] = -1
  Yhat[Yhat>=0] = 1
  
  #Caucula a AUC e ACC
  acc<-sum(diag(table(Yhat,testY)))/sum(table(Yhat,testY))
  #auc = AUC::auc(AUC::roc(Yhat,factor(testY)))
  
  #Retorna -AUC para a otimiza��o
  out = -acc
  
  return(out)
}

#Preenchimento de NAs
replaceNAsByMedian <- function(X)
{
  for(i in 1:ncol(X))
  {
    X[is.na(X[,i]),i] <- median(na.omit(X[,i])) 
  }
  return(X)
}

#Treina e testa SVM gen�rico
trainAndTestSVM <- function(trainX,trainY,testX,testY,C,g)
{
  #Treina e constr�i o modelo
  svm.model = svm(trainY ~ ., data=trainX,
                  cost=C,gamma=g)
  
  #Prediz a classe das amostras de teste
  Yhat = as.numeric(predict(svm.model,testX))
  
  #Aplica o limiar
  Yhat[Yhat<0] = -1
  Yhat[Yhat>=0] = 1
  
  #Caucula a AUC e ACC
  acc<-sum(diag(table(Yhat,testY)))/sum(table(Yhat,testY))
  #auc = AUC::auc(AUC::roc(Yhat,factor(testY)))
  
  #Retorna -AUC para a otimiza��o
  out<- acc
  
  return(out)
}

#Define classes
decodeClass <- function(X)
{
  X = as.factor(X)
  n = length(levels(X))
  if(n<=2)
  {
    Y = c()
    Y[which(X==levels(X)[1])] = 1
    Y[which(X==levels(X)[2])] = -1
  }else
  {
    Y = matrix(-1,nrow(nrow(X)),ncol=n)
    for(i in 1:n)
    {
      Y[which(X==levels(X)[i]),i]<--1
    }
  }
  return(Y)
}

#Plota evolu��o da popula��o
plotFobj <- function(x)
{
  #Labels p/ legenda
  Legenda = c()
  Legenda[1:length(x[[1]])] = "Jbest"
  Legenda[(length(x[[1]])+1):(length(x[[1]])+length(x[[2]]))] = "Jmed"
  
  
  #Dataframe para ggplot
  df = data.frame(
    Generations = (1:length(x[[1]])),
    Fitness = c(x[[1]],x[[2]]),
    Legend = Legenda
  )
  
  #Plot das fun��es objetivo
  ggplot(data=df, aes(x=Generations, y=Fitness, color=Legend)) +
    geom_line(size=0.8) +
    theme(legend.position="bottom",plot.title = element_text(hjust = 0.5)) + 
    ggtitle("Evolu��o da popula��o")
  
}

crossValidation <- function(trainX,trainY,Crange,gammarange)
{
  idx = createFolds(1:nrow(trainX), k = 10)
  acc.svm = matrix(0, nrow=length(gammarange),ncol=length(Crange))
  for(i in 1:length(gammarange))
  {
    for(j in 1:length(Crange))
    {
      acc<-c()
      auc<-c()
      t0<-Sys.time()
      for(k in 1:10)
      {
        acc[k] <- trainAndTestSVM(trainX = trainX[-idx[[k]],],
                                  trainY = trainY[-idx[[k]]],
                                  testX = trainX[idx[[k]],],
                                  testY = trainY[idx[[k]]],
                                  C = Crange[j],g = gammarange[i])
      }
      acc.svm[i,j]<-mean(acc)
      print(Sys.time()-t0)
      print(c("Internal LOOP:",j,"External LOOP:",i))
      print(c(acc.svm[i,j]))
    }
    
    return(acc.svm)
    
  }
  
  output <- list(AUC = auc.svm, ACC = acc.svm)
  return(output)
  
}

#Tempo de execu��o
t0 <- Sys.time()

#------------------------------------Defini��o dos dados
full.data <- read_csv("~/Sistemas Nebulosos/TP3/data2d.csv", 
                      col_names = FALSE)

#Defini��o dos nomes
colnames(full.data) <- c("X1data","X2data","Ydata")

X <- data.matrix(full.data[,1:2])
Y <- data.matrix(full.data[,3])

#-----------------------------------Defini��o da otimiza��o
#Limites
Llim<-c(-12,-5)
Ulim<-c(4,15)

#Otimiza��o
DE.out <- diffEvo(trainAndTestSVM.OBJ,Llim,Ulim,40)
plotFobj(DE.out)

C.best <- 10^DE.out$best.ind[1]
gamma.best <- 10^DE.out$best.ind[2]

#CV
caret.data <- full.data
caret.data$Ydata <- factor(full.data$Ydata)
levels(caret.data$Ydata) <- c("c1","c2")
ctrl <- trainControl(method = "cv", savePred=T, classProb=T)
mod <- caret::train(Ydata ~., data=caret.data, 
                    method = "svmLinear2", trControl = ctrl)

caret.cost <- mod$finalModel$cost
caret.gamma <- mod$finalModel$gamma

acc.final.caret<-c()
acc.final <- c()
for(i in 1:30)
{
  splitIndex <- createDataPartition(Y,times=1,p=0.7,list=FALSE)
  trainX <- X[splitIndex,]
  testX <- X[-splitIndex,]
  trainY <- Y[splitIndex]
  testY <- Y[-splitIndex]
  
  #Acur�cia de classifica��o DE
  acc.final[i] <- trainAndTestSVM(trainX,trainY,testX,
                                  testY,C.best,gamma.best)
  
  #Acur�cia Caret
  acc.final.caret[i] <- trainAndTestSVM(trainX,trainY,testX,
                                    testY,caret.cost,caret.gamma) 
}

print(mean(acc.final))
print(sd(acc.final))

print(mean(acc.final.caret))
print(sd(acc.final.caret))

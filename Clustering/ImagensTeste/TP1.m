clear all;
clc;

img = (imread('photo003.jpg'));
imshow(img);

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

%scatter3(r(:),g(:),b(:));

x = [r(:) g(:) b(:)];
x = double(x);

%Definindo as dimens�es do problema
k = 12;          %n� de clusters
n = size(x,1);  %n� de dados
d = size(x,2);  %n� de dimens�es


%Inicializando matriz de pertin�ncia de forma aleat�ria
U = zeros(n,k);
rng('shuffle');
for i = 1:n
    aux = rand(1,k);
    aux = aux/sum(aux);
    U(i,:) = aux;
end

changes = true; %Vari�vel da condi��o de parada
iter = 0;       %Vari�vel para o n� de itera��es
t = zeros(k,d);
while(changes)
    
    %1. C�lculo dos centr�ides
    centroids = zeros(k,d);
    for i = 1:k
        for j = 1:d
            centroids(i,j) = sum((U(:,i).^2).*x(:,j))/sum(U(:,i).^2);
        end
    end
    
    %2. Computando a fun��o de custo
    Jaux = 0;
    for i = 1:n
        for j = 1:k
            Jaux = Jaux + U(i,j)*norm(x(i,:)-centroids(j,:))^2;
        end
    end
    iter = iter+1;
    J(iter) = Jaux;
    
    %3. Computando a nova matriz U
    for i = 1:n
        for j = 1:k
            if(x(i,1)==centroids(j,1) && x(i,2)==centroids(j,2))
                U(i,:) = 0;
                U(i,j) = 1;
            else
                dist = norm(x(i,:)-centroids(j,:));
                total.dist = 0;
                for aux = 1:k
                    total.dist = total.dist + ...
                        norm(x(i,:)-centroids(aux,:));
                end
                U(i,j) = 1/(dist/total.dist)^2;
            end
        end
    end
    
    %Normalizando a matriz U
    for i = 1:n
        U(i,:) = U(i,:)/sum(U(i,:));
    end
    
    %Verificando a condi��o de parada
    tol = sum(sum((centroids-t)*(centroids-t)'))/length(centroids);
    if (iter>5 && (iter>150 || tol<1e-3))
        changes = false;
    end
    
    out = ['Itera��o:',num2str(iter),';     J=',num2str(Jaux),';        Tol=',num2str(tol)];
    disp(out);
    fprintf('CENTR�IDS:\n');
    disp(centroids);
    fprintf('\n');
    tminus = t;
    t = centroids;
    
end

%Definindo as classes dominantes
for i = 1:n
    [~,idx] = max(U(i,:));
    x(i,:) = centroids(idx,:);
end

x = reshape(x,size(img));
x = uint8(x);
imshow(x);

imwrite(x,'flores.jpg')

function [ T ] = oss( data, ic, mjclass, minclass, initmaj )
c0 = find(data(:,ic) == minclass);
c1 = find(data(:,ic) == mjclass);

C = data(c0,:);
%C = [C; data(c1(randi(size(c1,1),1),1),:)];
C = [C; data(c1(unique(randi(size(c1,1),initmaj,1)),1),:)];

fprintf('Rodando Knn...\n');
saida = knnclassify(data(:,1:ic-1), C(:,1:ic-1), C(:,ic));
fprintf('Fim Knn...\n');
classes = data(:,ic);

ierros = find((saida - classes) ~= 0);
C = [C; data(ierros,:)];

fprintf('Tamanho C: %d\n', size(C,1));

T = tomeklink(C, ic, mjclass);

end


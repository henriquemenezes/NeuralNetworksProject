data = [[1 1 0]
        [2 3 0]
        [3 1 0]
        [2 2 1]
        [4 4 1]
        [5 5 1]
        [1 0 1]
        [5 6 1]
        [4 5 1]
        [5 5 1]
        [6 6 1]
        [7 6 1]
        [9 2 1]
        [10 9 1]
        [8 9 1]
        [12 12 1]];

ic = 3;
c0 = find(data(:,ic) == 0);
c1 = find(data(:,ic) == 1);

%hold on;
%plot(data(c0,1), data(c0,2), 'b*');
%plot(data(c1,1), data(c1,2), 'go');

C = data(c0,:);
C = [C; data(c1(randi(size(c1,1),1),1),:)];
saida = knnclassify(data(:,1:ic-1), C(:,1:ic-1), C(:,ic));
classes = data(:,ic);
res = [saida classes (saida - classes)]
ierros = find((saida - classes) ~= 0);
C = [C; data(ierros,:)];
data(ierros,:)

%nc0 = find(C(:,ic) == 0);
%nc1 = find(C(:,ic) == 1);

%hold on;
%plot(C(nc0,1), C(nc0,2), 'b*');
%plot(C(nc1,1), C(nc1,2), 'go');

% remove tomek link
T = tomeklink(C, ic, 1);

tc0 = find(T(:,ic) == 0);
tc1 = find(T(:,ic) == 1);

hold on;
plot(T(tc0,1), T(tc0,2), 'b*');
plot(T(tc1,1), T(tc1,2), 'go');
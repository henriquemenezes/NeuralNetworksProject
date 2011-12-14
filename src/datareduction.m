data = dlmread('databases/original-validation.csv');

[N ic] = size(data);
classe0 = size(find(data(:,ic) == 0),1);
classe1 = N - classe0;

if classe0 > classe1,
    mjclass = 0;
    minclass = 1;
else
    mjclass = 1;
    minclass = 0;
end;

reduced = oss(data, ic, mjclass, minclass, 1000);

csvwrite('databases/reduced-validation.csv', reduced);
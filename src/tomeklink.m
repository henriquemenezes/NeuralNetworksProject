function [ data ] = tomeklink( data, ic, majClass )

min_dist = zeros(size(data,1), 1);
tomek_link = [];

h = waitbar(0,'TOMEK LINK..');

for i = 1 : size(data, 1)
    waitbar(i/size(data, 1))
    sample_mat = repmat(data(i,1:ic-1), size(data,1), 1);
    dists = sum(abs(data(:,1:ic-1) - sample_mat), 2);
    [ds, id] = sort(dists);    
    if data(id(2),ic) ~= data(i,ic),
        min_dist(i) = id(2);
        if min_dist(id(2)) == i,
            %tomek_link
            if data(i,ic) == majClass,
                tomek_link = [tomek_link i];
            else
                tomek_link = [tomek_link id(2)];
            end
        end;
    end
end

data(tomek_link,:) = [];

close(h);

end


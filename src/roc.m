function [tp, fp] = roc(t, y)

% process targets

%t = t > 0;

% sort by classifier output

[Y,idx] = sort(-y);
t       = t(idx);

% compute true positive and false positive rates

tp = cumsum(t)/sum(t);
fp = cumsum(~t)/sum(~t);

% add trivial end-points

tp = [0 ; tp ; 1];
fp = [0 ; fp ; 1];
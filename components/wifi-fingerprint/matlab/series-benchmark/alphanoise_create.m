clear
clc
for i=1:10
%     alphanoise(i,:)=stblrnd(1.3,0,0.1,0,[2000 1]);
    alphanoise(i,:)=stblrnd(1.1,0,0.1,0,[5000 1]);
end
save alphanoise
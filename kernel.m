function K = kernel(X1,X2,kerneltype,sigma)
% PPT 的公共核函数接口：每行一个样本。
% 当前定位示例使用 gauss 核，sigma 是高斯核宽度。
assert(strcmp(kerneltype,'gauss'),'KAF:KernelType','本实验只实现 PPT 使用的 gauss 核。');
validateattributes(sigma,{'double'},{'scalar','real','finite','positive'});
distanceSquared = sum(X1.^2,2)+sum(X2.^2,2)'-2*(X1*X2');
K = exp(-max(distanceSquared,0)/(2*sigma^2));
end

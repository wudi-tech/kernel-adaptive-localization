function value=GetRssiValue(d)
A = -42;
n = 2;
value = A-10*n*log10(d);
Q = 5;
value = value + sqrt(Q)*randn;
end


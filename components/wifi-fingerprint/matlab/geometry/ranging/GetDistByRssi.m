function value = GetDistByRssi(rssi)
A = -42;
n = 2;
value = 10^((A-rssi)/10/n);
end

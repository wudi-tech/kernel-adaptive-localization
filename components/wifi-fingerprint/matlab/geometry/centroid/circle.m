%画圆函数，必须写在另一个m文件中
function circle(x0, y0, r)
    sita=0:pi/20:2*pi;
    plot(x0+r*cos(sita), y0+r*sin(sita));
end
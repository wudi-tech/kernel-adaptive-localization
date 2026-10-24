function [dist, dist2]=DIST(A, B)
    dist2 = (A.x-B.x)^2+(A.y-B.y)^2;
    dist = sqrt(dist2);
end
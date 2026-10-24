clear all;
close all;
clc
%定位初始化
Length = 100; %定位场地大小
Width = 100;
Node_number = 3; %观测站个数
for i=1:Node_number %观测站位置随机设定
    Node(i).x = Width*rand;
    Node(i).y = Length*rand;
    Node(i).D = Node(i).x^2+Node(i).y^2;
end

%目标位置随机设定
Target.x = Width*rand;
Target.y = Length*rand;
BroadcastPacket=0; %数据包，用于目标节点周期性广播数据包和超声波
ultrasonicV=340; %声波速度
sendData(BroadcastPacket); %目标节点发送电磁波
delaytime = 10; %延迟一段时间后，发送超声波
delay(delaytime);
%目标节点发送超声脉冲
sendUltraPlus();

uI=[]; %各个观测站采集时间差
for i=1:Node_number
    recvUltraPlus();
    [d]=DIST(Node(i),Target); %观测点离目标的真实距离
    uI(i) = GetTimeLength(d); %第i个观测点记录的时间
end

Zd=[];
for i=1:Node_number
    Zd(i)=uI(i)*ultrasonicV; %第i个观测点与目标之间的距离
end

H=[];b=[];
for i=2:Node_number %三边测距法
    H = [H;2*(Node(i).x-Node(1).x), 2*(Node(i).y-Node(1).y)];
    b = [b;Zd(1)^2-Zd(i)^2+Node(i).D-Node(1).D];
end
Estimate = inv(H'*H)*H'*b; %最小二乘法估计位置
Est_Target.x = Estimate(1); Est_Target.y = Estimate(2);

figure
hold on; box on; axis([0 120 0 120]);
for i=1:Node_number
    h1 = plot(Node(i).x,Node(i).y,'ko','MarkerFace','g','MarkerSize',10);
    text(Node(i).x+2,Node(i).y,['Node',num2str(i)]);
end
h2 = plot(Target.x,Target.y,'k^','MarkerFace','b','MarkerSize',10);
h3 = plot(Est_Target.x,Est_Target.y,'ks','MarkerFace','r','MarkerSize',10);
line([Target.x,Est_Target.x],[Target.y,Est_Target.y],'Color','k');
legend([h1,h2,h3],'观测站','真实位置','估计位置');
[Error_Dist]=DIST(Est_Target,Target);
xlabel(['error=',num2str(Error_Dist),'m']);
set(gcf,'Color','w');
title('TDOA定位算法')


% ------------------ 以下为函数定义 ------------------

function [dist]=DIST(A,B)
    dist = sqrt((A.x-B.x)^2+(A.y-B.y)^2);
end

function time = GetTimeLength(d)
    ultrasonicV = 340;
    time = d/ultrasonicV;
    Q = 5e-6;
    time = time+sqrt(Q)*randn;
end

function sendData(BroadcastData)
    disp('The target send wireless data success!\n')
end

function sendUltraPlus()
    disp('The target send ultra plus success!\n')
end

function recvUltraPlus()
    disp('The ObserverNode receive ultra plus success!\n')
end

function delay(delaytime)
    disp('System delay for sometime!\n')
end
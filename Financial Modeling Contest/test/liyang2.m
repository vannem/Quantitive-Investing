%% liyang
clc;clear;close all;
% function MatlabTradingDemo
load data_minute_2012

IFdata = Close(1001:1500);%793*1
ShortLen=5;
LongLen=20;
[MA5,MA20]=movavg(IFdata,ShortLen,LongLen);%tsmovavg
MA5(1:ShortLen-1)=IFdata(1:ShortLen-1);
MA20(1:LongLen-1)=IFdata(1:LongLen-1);
figure
plot([IFdata,MA5,MA20]);
grid on;
legend('IF888','MA5','MA20','Location','Best');
title('���ײ��Իز����')
hold on

%% ���׹��̷���
%��λPos=1��ͷ1�֣�Pos=0�ղ֣�Pos=-1��ͷ1��
Pos=zeros(length(IFdata),1);
%��ʼ�ʽ�
InitialE=50e4;
%�������¼
ReturnD=zeros(length(IFdata),1);
%��ָ����
scale=300;

for t=LongLen:length(IFdata)
    %�����źţ�5�վ����ϴ�20�վ���
    SignalBuy=MA5(t)>MA5(t-1) && MA5(t)>MA20(t) && MA5(t-1)>MA20(t-1) && MA5(t-2)<=MA20(t-2);
    %�����źţ�5�վ�������20�վ���
    SignalSell=MA5(t)<MA5(t-1) && MA5(t)<MA20(t) && MA5(t-1)<MA20(t-1) && MA5(t-2)>=MA20(t-2);
    %��������
    if SignalBuy==1
        %�ղֿ���ͷ1��
        if Pos(t-1)==0
            Pos(t)=1;
            text(t,IFdata(t),'\leftarrow����1��','FontSize',8);
            plot(t,IFdata(t),'ro','markersize',8);
            continue
        end
        %ƽ��ͷ����ͷ1��
        if Pos(t-1)==-1
            Pos(t)=1;
            ReturnD(t)=(IFdata(t-1)-IFdata(t))*scale;
            text(t,IFdata(t),'\leftarrowƽ�տ���1��','FontSize',8);
            plot(t,IFdata(t),'ro','markersize',8);
            continue
        end
    end
    
    %��������
    if SignalSell==1
        %�ղֿ���ͷ1��
        if Pos(t-1)==0
            Pos(t)=-1;
            text(t,IFdata(t),'\leftarrow����1��','FontSize',8);
            plot(t,IFdata(t),'rd','markersize',8);
            continue;
        end
        %ƽ��ͷ����ͷ1��
        if Pos(t-1)==1
            Pos(t)=-1;
            ReturnD(t)=(IFdata(t)-IFdata(t-1))*scale;
            text(t,IFdata(t),'\leftarrowƽ�࿪��1��','FontSize',8);
            plot(t,IFdata(t),'rd','markersize',8);
            continue;
        end
    end
    
    %ÿ��ӯ������
    if Pos(t-1)==1
        Pos(t)=1;
        ReturnD(t)=(IFdata(t)-IFdata(t-1))*scale;
    end
    if Pos(t-1)==-1
        Pos(t)=-1;
        ReturnD(t)=(IFdata(t-1)-IFdata(t))*scale;
    end
    if Pos(t-1)==0
        Pos(t)=0;
        ReturnD(t)=0;
    end
    
    %���һ��������������гֲ֣�����ƽ��
    if t==length(IFdata) && Pos(t-1)~=0
        if Pos(t-1)==1
            Pos(t)=0;
            ReturnD(t)=(IFdata(t)-IFdata(t-1))*scale;
            text(t,IFdata(t),'\leftarrowƽ��1��','FontSize',8);
            plot(t,IFdata(t),'rd','markersize',8);
        end
        if Pos(t-1)==-1
            Pos(t)=0;
            ReturnD(t)=(IFdata(t-1)-IFdata(t))*scale;
            text(t,IFdata(t),'\leftarrowƽ��1��','FontSize',8);
            plot(t,IFdata(t),'ro','markersize',8);
        end
    end    
end

%% �ۼ�����
ReturnCum=cumsum(ReturnD);
ReturnCum=ReturnCum+InitialE;

%% �������س�
MaxDrawD=zeros(length(IFdata),1);
for t=LongLen:length(IFdata)
    C=max(ReturnCum(1:t));
    if C==ReturnCum(1:t)
        MaxDrawD(t)=0;
    else
        MaxDrawD(t)=(ReturnCum(t)-C)/C;
    end
end
MaxDrawD=abs(MaxDrawD);

%% ͼ��չʾ
figure
subplot(3,1,1);
plot(ReturnCum);
grid on;
axis tight;
title('��������');
subplot(3,1,2);
plot(Pos,'LineWidth',1.8);
grid on;
axis tight;
title('��λ');

subplot(3,1,3);
plot(MaxDrawD);
grid on;
axis tight;
title(['���س�����ʼ�ʽ�','num2str(InitialE/1e4),']);



function test2(symbol,startvec,endvec,Money,bRate,sRate,n,percent,indicator)
%% ==================* Quantitive-Investing *==============================
%      https://github.com/zihaolucky/Quantitive-Investing
%

%% Initialize Variables.

% initial price, usable money
p0=Open(1);
iniStocks=fix(Money*percent/(p0*100));
MoneyFree=Money-p0*iniStocks*100*1.005;
% capital
Capital=Close(1)*iniStocks*100+MoneyFree;
capital=[Capital];
% value
Value=Close(1)*100;
% cost/share
S_cost=p0*1.005;

% a vecot contains the buy & sell
pBuy=[repmat(p0,[1,iniStocks])];
pSell=[];

% sell, bug day
sDay=[];  
bDay=[1];

% total profit, profit/day
T_profit=0;

profit=zeros(1,items);

% Average Price & gradient MA.
[Short,Med,Long]=SimpleMovingAverage(Close,indicator);
[gra_S,gra_M,gra_L]=graMA(Short,Med,Long);

%%
fprintf('The initial price is %2.2f.... Press enter to continue.\n\n',p0);
pause;

%% first method: no average price calculation.
for i=2:items

    fprintf('---- Day %d ----\n',i)
    fprintf('Stocks: %d\n',size(pBuy,2))
    fprintf('MoneyFree: %2.2f\n\n',MoneyFree)
    
    % when we don't have any stocks
    if size(pBuy,2)==0 && MoneyFree>Open(i)*fix(MoneyFree*percent/(Open(i)*100))*100*1.005
        pBuy=[repmat(Open(i),[1,fix(MoneyFree*percent/(Open(i)*100))])];
        % a bug here when testing 600880.ss
        fprintf('Trading again !\n')
        fprintf('    Buy!\n')
        fprintf('Price: %2.2f\n',pBuy(end))
        MoneyFree=MoneyFree-pBuy(end)*fix(MoneyFree*percent/(Open(i)*100))*100*1.005;
        bDay=[bDay,i];
        S_cost=mean(pBuy);
    end
    
    % we have stocks
    if size(pBuy)>0
        if S_cost*(1-bRate)>Low(i) && MoneyFree>S_cost*(1-bRate)*n*100*1.005 &&...
                
            pBuy=[pBuy,repmat(pBuy(end)*(1-bRate),[1,n])];
            fprintf('    Buy!\n')
            fprintf('Price: %2.2f\n',pBuy(end))
            MoneyFree=MoneyFree-pBuy(end)*n*100*1.005;
            bDay=[bDay,i];
            S_cost=mean(pBuy);
        end
        % to make sure this part is doing T
        if pBuy(end)*(1+sRate)<High(i) && Low(i)<pBuy(end)*(1+sRate) && size(pBuy,2)>iniStocks
            profit(i)=pBuy(end)*sRate*n*100*0.995;
            sDay=[sDay,i];
            fprintf('    Sell!\n')
            fprintf('Price: %2.2f\n\n',pBuy(end)*(1+sRate))
            MoneyFree=MoneyFree+pBuy(end)*n*100*0.995;
            pBuy=[pBuy(1:end-n)];
            S_cost=(sum(pBuy)*100-profit(i))/(size(pBuy,2)*100);
            fprintf('Cost/share: %2.2f \n',S_cost)
        end
        % arbitrage--sell out!
        if S_cost<=Open(i)*0.8 && S_cost>0
            profit(i)=(Open(i)-S_cost)*size(pBuy,2)*100*n;
            fprintf(' Arbitrary.   Sell Out !\n')
            fprintf('Price: %2.2f\n\n',Open(i))
            MoneyFree=MoneyFree+Open(i)*size(pBuy,2)*100*0.995;
            pBuy=[];
            S_cost=0;
            sDay=[sDay,i];
            fprintf('Cost/share: %2.2f \n',S_cost)
        end
        % sell out! STOP LOSS
        if gra_S(i-1)+gra_M(i-1)+gra_L(i-1)<=0 && S_cost>0 
            profit(i)=(Open(i)-S_cost)*size(pBuy,2)*100;
            fprintf('    Sell Out ! STOP LOSS...\n')
            fprintf('Price: %2.2f\n\n',Open(i))
            MoneyFree=MoneyFree+Open(i)*size(pBuy,2)*100*0.995;
            pBuy=[];
            S_cost=0;
            sDay=[sDay,i];
            fprintf('Cost/share: %2.2f \n',S_cost)
        end
    end
    

    
    Value=(Close(i)*size(pBuy,2)*100);
    Capital=Value+MoneyFree;
    
    T_profit=T_profit+profit(i);
    capital=[capital Capital];
end

fprintf('Trading end... \n\n')
fprintf('Finally, the Value of our stocks are %2.2f yuan.\n',Value)
fprintf('Finally, our Total profit is %2.2f yuan.\n',T_profit)
fprintf('Finally, our Total Capital is %2.2f yuan.\n',Capital)

%% Visualize the flatuation of price and profit
figure(1);
subplot(2,1,1)
plot(1:items,Close,'linewidth',1.3,'color','r')
hold on

plot(sDay,Close(sDay),'b.')
plot(bDay,Close(bDay),'g.')
title({symbol},'FontSize',12)
s_date=[num2str(startvec(1)) '-' num2str(startvec(2)) '-' num2str(startvec(3))];
ylabel('Price','FontSize',12)
hold off

%
subplot(2,1,2)
N=fix(Money/(Open(1)*100));
Moneyfree=Money-N*Open(1)*100;
plot(1:items,capital,'linewidth',1.3,'color','b')
hold on
plot(1:items,Close*100*N+Moneyfree,'linewidth',1.3,'color','r')
title('Comparison','FontSize',12)
xlabel({'Start from',s_date},'FontSize',12)
ylabel('Capital','FontSize',12)
legend('With Stretegy','Normal Style')

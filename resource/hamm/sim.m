clear;
clc;

Uni_V2_USDT_ETH_XY = [130687499.0, 30071.0];
Nftx_Sushi_PUNK_ETH_XY = [1614.784, 23.381];

rVec = [0.1, 0.2, 0.3, 0.5, 0.8, 1];
rCol = ["r", "b", "g", "m", "y", "c"];
rLine = ["-", "--", "-", "--", "-", "--"];
step = 1000;

%%%%%%%%%%%%%%%%%%%%%% Trading Curve Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
pool_XY = Uni_V2_USDT_ETH_XY;
% pool_XY = Nftx_Sushi_PUNK_ETH_XY;
c = pool_XY(1) * pool_XY(2);
hold on;
hammYVecs = zeros(length(rVec), step+1);
xMin = 0;
xVecs = zeros(length(rVec), step+1);
for pool_r_index = 1:length(rVec)
    pool_r = rVec(pool_r_index);
    xMax = (1+pool_r)^2 * c / (pool_r*pool_XY(2)) - pool_r * pool_XY(1);
    xInterval = (xMax - xMin) / step;
    xVecs(pool_r_index, :) = xMin : xInterval : xMax;
    hammYVecs(pool_r_index, :) = hammTradingCurve(xVecs(pool_r_index, :), pool_r * pool_XY(1), pool_r * pool_XY(2), (1 + pool_r)^2*c);
end
limitYMax = min(hammYVecs(:, 1));
limitXMax = min(xVecs(:, step+1));

xVecAmm = pool_XY(1)/100 : (limitXMax-pool_XY(1)/100)/(step^2):limitXMax;
ammYVec = ammTradingCurve(xVecAmm, c);
ammIndexs = find(ammYVec <= limitYMax);
plot(xVecAmm(ammIndexs), ammYVec(ammIndexs), 'k');

for pool_r_index = 1:length(rVec)
    is = find(xVecs(pool_r_index, :) <= limitXMax & hammYVecs(pool_r_index, :) <= limitYMax); % limitXIndex
    lineStyle = strcat(rCol(pool_r_index),rLine(pool_r_index));
    plot(xVecs(pool_r_index, is), hammYVecs(pool_r_index, is), lineStyle);
end

grid on;
hold off;
title("Trading Curve")
xlabel({'USD amount'})
ylabel({'ETH amount'})
legend({
    " AMM--r= 0 "...
    "hAMM--r=0.1"...
    "hAMM--r=0.2"...
    "hAMM--r=0.3"...
    "hAMM--r=0.5"...
    "hAMM--r=0.8"...
    "hAMM--r=1.0"...
    });
%%%%%%%%%%%%%%%%%%%%%% Trading Curve End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fee = 0.003;

%%%%%%%%%%%%%%%%%%%%%% Slippage Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
pool_XY = Uni_V2_USDT_ETH_XY;
% pool_XY = Nftx_Sushi_PUNK_ETH_XY;

c = pool_XY(1) * pool_XY(2);
currentPrice = pool_XY(1) / pool_XY(2);
xMin = 0;

delta_x = pool_XY(1) / 100;
% delta_x = 1;

xrVecs = zeros(length(rVec), step + 1);
yrVecs = zeros(length(rVec), step + 1);
pVecs = zeros(length(rVec), step + 1);
hammSpVecs = zeros(length(rVec), step + 1);
for pool_r_index = 1:length(rVec)
    pool_r = rVec(pool_r_index);
    ch = c * (1+pool_r)^2;
    xv = pool_r * pool_XY(1);
    yv = pool_r * pool_XY(2);
    xrMax = ch / yv - xv;
    xrMin = 0;
    xrVec = xrMin: (xrMax-xrMin)/step : xrMax;
    
%     highestPrice = xrMax / (ch / xrMax);
%     xrVec = logspace(log10(10), log10(highestPrice), step + 1);
    
    xtVec = xrVec + xv;
    ytVec = ch ./ xtVec;
    yrVec = ytVec - yv;
    hammSpVecs(pool_r_index, :) = hammPriceSlippageByX(xrVec, yrVec, xv, yv, fee, delta_x);
    xrVecs(pool_r_index, :) = xrVec;
    yrVecs(pool_r_index, :) = yrVec;
    pVecs(pool_r_index, :) = (xrVec + xv) ./ ytVec;
end

limitPMax = currentPrice * 5;
limitPMin = currentPrice / 5;

xMin = xMax/100;
xMax = sqrt(c * max(pVecs(:, step + 1)));% xMax should be the value where yamm_min = c / xMax & xMax / yamm_min = max(pVecs(:, step + 1))
ammXVec = xMin: (xMax-xMin)/step:xMax;
ammYVec = c./ammXVec;
ammPVec = ammXVec ./ ammYVec;
ammSpVec = ammPriceSlippageByX(ammXVec, ammYVec, fee, delta_x);
ammIndexs = find(ammPVec <= limitPMax & ammPVec >= limitPMin);
plot(ammPVec(ammIndexs), ammSpVec(ammIndexs), 'k');
hold on;

for pool_r_index = 1:length(rVec)
    is = find(pVecs(pool_r_index, :) <= limitPMax & pVecs(pool_r_index, :) >= limitPMin);
    lineStyle = strcat(rCol(pool_r_index),rLine(pool_r_index));
    plot(pVecs(pool_r_index, is), hammSpVecs(pool_r_index, is), lineStyle);
end
grid on;
hold off;
title("Slippage Curve when trading 1%");
xlabel({'ETH price in USD'})
ylabel({'Slippage'})
legend({
    " AMM--r= 0 "...
    "hAMM--r=0.1"...
    "hAMM--r=0.2"...
    "hAMM--r=0.3"...
    "hAMM--r=0.5"...
    "hAMM--r=0.8"...
    "hAMM--r=1.0"...
    });
%%%%%%%%%%%%%%%%%%%%%% Slippage End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%% Cost to Move Price Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3)
pool_XY = Uni_V2_USDT_ETH_XY;
% pool_XY = Nftx_Sushi_PUNK_ETH_XY;

% price is defined as x / y (in the unit of Y), say X = usdt, Y = eth
priceChanges = -0.9 : 0.01 : 2;
ammCosts = zeros(1, length(priceChanges));
hammCosts = zeros(length(rVec), length(priceChanges));
ammCosts = ammCost(priceChanges, pool_XY(1), pool_XY(2), fee);

for pool_r_index = 1:length(rVec)
    pool_r = rVec(pool_r_index);
    pool_XY_R = pool_XY * pool_r;
    hammCosts(pool_r_index, :) = hammCost(priceChanges, pool_XY(1), pool_XY(2), fee,  pool_XY_R (1), pool_XY_R (2));
end


plot(priceChanges, ammCosts, 'k');
hold on;
for pool_r_index = 1:length(rVec)
    is = (~hammCosts(pool_r_index, :)==0);
    lineStyle = strcat(rCol(pool_r_index),rLine(pool_r_index));
    plot(priceChanges(is), hammCosts(pool_r_index, is), lineStyle);
end
grid on;
hold off;
title("Cost Percentage to Move price")
xlabel({'Price change Percentage'})
ylabel({'Cost of Asset'})
legend({
    " AMM--r= 0 "...
    "hAMM--r=0.1"...
    "hAMM--r=0.2"...
    "hAMM--r=0.3"...
    "hAMM--r=0.5"...
    "hAMM--r=0.8"...
    "hAMM--r=1.0"...
    });
hold off;
% 
% %%%%%%%%%%%%%%%%%%%%%% Cost to Move Price End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% without fee
function output = ammTradingCurve(xVec, c)
    output = c ./ xVec;
end

% without fee
function output = hammTradingCurve(xrVec, xv0, yv0, ch)
    xVec = xrVec + xv0;
    output = ch ./ xVec - yv0;
end





% (x, y) is one point in amm coordinate, then we explore the Slippage given
% a small amount of delta_x assumed as 1
function output = ammPriceSlippageByX(xVec, yVec, fee, delta_x)
    % x * y = c = [x + delta_x * (1-fee)](y + delta_y)
    delta_y = xVec .* yVec ./ (xVec + delta_x * (1-fee)) - yVec;
    priceInitial = xVec ./ yVec;
    output = abs(priceInitial - (xVec + delta_x) ./ (yVec + delta_y)) ./ priceInitial * 100;
end


function output = hammPriceSlippageByX(xVec, yVec, xv0, yv0, fee, delta_x)
   delta_y = (xVec + xv0) .* (yVec + yv0) ./ (xVec + xv0 + delta_x * (1-fee)) - yv0 - yVec;
   priceInitial = (xVec+xv0) ./ (yVec + yv0);
   output = abs(priceInitial - (xVec + xv0 + delta_x ) ./ (yVec + yv0 + delta_y)) ./ priceInitial * 100;
end



% elements of priceChanges strictly > -1
function output = ammCost(priceChanges, x0, y0, fee)
    c0 = x0 * y0;
    p0 = x0 / y0;
    p1Vec = p0 * (1 + priceChanges);

    % Now the price is p1, there should be 
    % x0 * y0 = c0 = [x0 + delta_x * (1-fee)] * (y0 + delta_y)
    % p1 = (x0 + delta_x) / (y0 + delta_y)
    % c1 = (x0 + delta_x) * (y0 + delta_y)
    % trading price tp = abs(delta_x / delta_y)
    % => 
    % (1-f) * delta_x^2 + (2-f)x0 * delta_x + x0^2-c0p1 = 0
    delta_xVec = sqrt(((2-fee)*x0).^2 - 4 * (1-fee) * (x0.^2-c0*p1Vec)) - (2-fee)*x0;
    delta_yVec = c0 ./ (x0 + delta_xVec * (1-fee)) - y0;

    % trading price: abs(delta_xVec ./ delta_yVec);
    % cost of token X: delta_xVec / x0;
    output = delta_xVec / x0;;
end



function output = hammCost(priceChanges, xr0, yr0, fee, xv0, yv0)
    x0 = xr0 + xv0;
    y0 = yr0 + yv0;
    c0 = x0 * y0;
    p0 = x0 / y0;

    p1Vec = p0 * (1 + priceChanges);

    % Now the price is p1, there should be 
    % (x0 * y0 = c0 = [x0 + delta_x * (1-fee)] * (y0 + delta_y)
    % p1 = (x0 + delta_x) / (y0 + delta_y)
    % c1 = (x0 + delta_x) * (y0 + delta_y)
    % trading price tp = abs(delta_x / delta_y)
    % => 
    % (1-f) * delta_x^2 + (2-f)x0 * delta_x + x0^2-c0p1 = 0
    delta_xVec = sqrt(((2-fee)*x0).^2 - 4 * (1-fee) * (x0.^2-c0*p1Vec)) - (2-fee)*x0;                
    delta_yVec = c0 ./ (x0 + delta_xVec * (1-fee)) - y0;

    output = zeros(1, length(priceChanges));
    effectiveIndexs = find(delta_xVec < xr0 & delta_yVec < yr0);
    % trading price: abs(delta_xVec(effectiveIndexs) ./ delta_yVec(effectiveIndexs));
    % cost of token X : delta_xVec(effectiveIndexs) / xr0;
    output(effectiveIndexs) = delta_xVec(effectiveIndexs) / xr0;
end

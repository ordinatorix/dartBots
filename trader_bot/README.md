a trading bot that buys assets at low price (dynamically set) and sells at a higher cost.
process flow: 
- connect wallet,
- execute function given [asset address], [buy price], [stopLoss (-%) = -0.5%]
- deposit on aave
- track asset price using DEX;
- on buy in price; borrow stable up to % LTV; 
- swap to asset
- compute re-swap price needed to cover previous buy-in gas, sell gas and borrowed amount.
- dca into asset as price rise [0.75; 0.25];
- on (- %) price change, swap stable;
- if asset pass threshold => deposit asset into aave;

on sushi, the router is used to query the price and to swap tokens
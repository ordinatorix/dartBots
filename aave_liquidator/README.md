# GETTING STARTED!

- Run mongo database
```
mongod --dbpath <path_to_db>/data/db
```
- check if db is running:
```
$mongosh
test> show dbs
test> show collections
test> show collections

#some useful db commands:
test> db.aaveReserve.find()
test> db.aaveReserve.countDocuments()
test> db.aaveReserve.drop()
test> exit()
```

- make sure you have access to chain network.
- run/debug app in vs code.










## Methodology brainstorm.

the percentage drop in collateral value can be calculated as follow:
* liquidation collateral price(LCP) = debt/liquidation_treshhold
* %drop to liquidate = 1-(LCP/col)

to calculate the % drop in sset value: 
* % drop token value = 1 - (token value@ liquidation/ token amount)/ current token price

---------------------

- use block mining time/interval to check account for liquidation.

-----------------

- query user based on preset frequency and health factor.
- get reserve list.
- getReserveConfigurationData(address asset) per asset.
- get asset price from aave @ reg frequency.
  - convert price in ETH

--------SIMPLE---------

- on chainlink price update
  - new price
- get user Health factor
  - if < 1 liquidate asset
 


--------COMPLEX--LONG-------

<!-- - group users based on collateral asset % (col_f)
  - if asset is stable; choose 1st variable asset
  - calc min col_f price for HF <= 1 ==> (LiqPrice) -->
- on price change from chainlink
  - calc price % change from aave price ==> aave trigger
    - calc price % change for aave
    - if price % change >= X% [https://docs.aave.com/risk/asset-risk/price-discovery-requirements] ==> then aave updated its prices
      - for each users holding asset     
        - calc new HF
          - if new HF < 1 liquidate asset with highest bonus.
        - update aave asset price
    - if < X% 
      - for each user holding asset
        - calc new HF
          - if HF <= 1 
            - get user account data
            - get asset price from aave



--------COMPLEX--SHORT-------

- group users based on debt asset % (col_f)
  - if asset is stable; choose 1st variable asset
  - calc min col_f price for HF <= 1 ==> (LiqPrice)
- listen for price change from chainlink
  - for each account in group
    - if current price == LiqPrice
      - if current price change >|1|% from last aave price
        - Liquidate account


----------------------------

i == asset
HF = sum(collateralETH[i] * liq_thresh[i])
     --------------------------------------
            [totalDebtETH]
 

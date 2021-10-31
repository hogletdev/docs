<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [1. BaseForward interfaces](#1-baseforward-interfaces)
  - [1.0 createOrder(...)](#10-createorder)
  - [1.1 cancelOrder(uint _orderId)](#11-cancelorderuint-_orderid)
  - [1.2 takeOrderFor(address _taker, uint _orderId)](#12-takeorderforaddress-_taker-uint-_orderid)
  - [1.3 deliverFor(address _deliverer, uint _orderId)](#13-deliverforaddress-_deliverer-uint-_orderid)
  - [1.4 settle(uint _orderId)](#14-settleuint-_orderid)
  - [1.5 Read methods](#15-read-methods)
    - [1.5.0 factory()](#150-factory)
    - [1.5.1 want()](#151-want)
    - [1.5.2 margin()](#152-margin)
    - [1.5.3 fVault()](#153-fvault)
    - [1.5.4 cfee()](#154-cfee)
    - [1.5.5 ordersLength()](#155-orderslength)
    - [1.5.6 paused()](#156-paused)
    - [1.5.7 balance()](#157-balance)
    - [1.5.8 getPricePerFullShare()](#158-getpriceperfullshare)
    - [1.5.9 checkOrderState(uint _orderId)](#159-checkorderstateuint-_orderid)
    - [1.5.9 getOrder(uint _orderId)](#159-getorderuint-_orderid)
- [2. Forward721 interfaces](#2-forward721-interfaces)
  - [2.1 createOrderFor(...)](#21-createorderfor)
  - [2.2 underlyingAssets(uint _orderId)](#22-underlyingassetsuint-_orderid)
- [3. Forward20 interfaces](#3-forward20-interfaces)
    - [3.1 createOrderFor(...)](#31-createorderfor)
  - [3.2 underlyingAssets(uint _orderId)](#32-underlyingassetsuint-_orderid)
- [4. Forward1155 interfaces](#4-forward1155-interfaces)
    - [4.1 createOrderFor(...)](#41-createorderfor)
  - [4.2 underlyingAssets(uint _orderId)](#42-underlyingassetsuint-_orderid)
- [5. ForwardEtherRouter](#5-forwardetherrouter)
- [6. BaseFactoryUpgradeable](#6-basefactoryupgradeable)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 1. BaseForward interfaces

### 1.0 createOrder(...)
As for the `createOrder`, the passed parameters are different when the forward assets are different. The details are provided in Forward721/Forward20/Forward1155 section bellow.

### 1.1 cancelOrder(uint _orderId)
param: 
```
_orderId, which order msg.sender wishes to cancel
```

### 1.2 takeOrderFor(address _taker, uint _orderId)

param:
```
_taker: who the sender would like represent for to take _orderId's forward order
_orderId: which order should be taken
```

Normally speaking, _taker would be the same as msg.sender. However, when the forward contract's margin is weth and the `_taker` would like to choose ether directly as weth, then we provide the ForwardEtherRouter contract to help taker wrap their ether into weth and take `_orderId`'s order for them.

### 1.3 deliverFor(address _deliverer, uint _orderId)
param:
```
_deliverer: who the sender would like represent for to deliver _orderId's forward order
_orderId: which order should be delivered
```
Note that only `_orderId`'s buyer and seller can be `_deliverer`.

### 1.4 settle(uint _orderId)
param:
```
_orderId: which order should be settled
```

### 1.5 Read methods

#### 1.5.0 factory()
```
return the factory contract address which created current forward contract.
```
#### 1.5.1 want()
```
return the forward asset address, can be ERC20, ERC721, ERC1155 type
```
####  1.5.2 margin()
```
return the margin token address of current forward contract pair (asset-margin pair mode)
```
#### 1.5.3 fVault()
```
return the forward yield farming vault contract address, can be empty address or valid vault contract address
```
#### 1.5.4 cfee()
```
return the cumulative fee currently left taxed from forward contract historical orders.
```
#### 1.5.5 ordersLength()
```
return how many forward orders of asset-margin pair have been created, no matter what happened to the order later.
```
#### 1.5.6 paused()
```
return if current forward contract has been paused or not. true:paused, false:not paused
```
#### 1.5.7 balance()
```
return how many margin tokens the forward contract holds currently
```

#### 1.5.8 getPricePerFullShare()
```
return the price of each share (from order's buyerShare or sellerShare). share unit should be 1e18, and the price unit should be margin token
```

#### 1.5.9 checkOrderState(uint _orderId)
```
_orderId: which order we would like to check the state of
return: real time state
```

Notice the returned value and its meaning are as follow.

return value | abbreviation | meaning
---|---|---
0 | inactive | order not exist/created on-chain
1 | active | order has been successfully created by maker
2 | filled | order has been filled by taker
3 | dead | order not filled till validTill timestamp
4 | delivery | order can be delivered, being challenged between buyer and seller
5 | expired | order is expired, yet not settled
6 | settled | order has been successfully settled
7 | canceled | order has been created and then canceled since no taker

#### 1.5.9 getOrder(uint _orderId)
```
_orderId: which order detail we would like to fetch
return: the details of a specific order
```
Notice that the order's detail are the same for Forward20, Forward721 and Forward1155 contract, the difference is the underlying asset behind a specific type of Forward contract, which will be provided in `underlyingAssets(uint _orderId)` interface.

```
struct Order {
    // using uint128 can help save 50k gas
    uint128 buyerMargin;
    uint128 sellerMargin;
    uint128 buyerShare;
    uint128 sellerShare;
    uint128 deliveryPrice;
    uint40 validTill;
    uint40 deliverStart;         // timpstamp
    uint40 expireStart;
    address buyer;
    address seller;
    bool buyerDelivered;
    bool sellerDelivered;
    State state;
    address[] takerWhiteList;  // indicates who can take this order being created
}
```


## 2. Forward721 interfaces

Inherit all the interfaces from BaseForward, besides, it contains the following.

### 2.1 createOrderFor(...)
Interface detail:
```
function createOrderFor(
    address _creator,
    uint[] memory _tokenIds, 
    // uint _orderValidPeriod,
    // uint _deliveryStart,
    // uint _deliveryPeriod,
    uint[] memory _times,
    // uint _deliveryPrice, 
    // uint _buyerMargin,
    // uint _sellerMargin,
    uint[] memory _prices,
    address[] memory _takerWhiteList,
    bool _deposit,
    bool _isSeller
)
```

parameter explanation:

```
_creator: the maker address, send wants to invoke this method representing for _creator
_tokenIds: array of tokenId, indicating what are the underlying assets, should be array of token ids from want() token of type ERC721
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _tokenIds into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```


### 2.2 underlyingAssets(uint _orderId)
```
return: array of uint, indicating what tokenIds set from _orderId's order is
```

## 3. Forward20 interfaces

#### 3.1 createOrderFor(...)

Interface detail:
```
function createOrderFor(
    address _creator,
    uint _underlyingAmount,
    // uint _orderValidPeriod,
    // uint _deliveryStart,
    // uint _deliveryPeriod,
    uint[] memory _times,
    // uint _deliveryPrice, 
    // uint _buyerMargin,
    // uint _sellerMargin,
    uint[] memory _prices,
    address[] memory _takerWhiteList,
    bool _deposit,
    bool _isSeller
)
```

parameter explanation:

```
_creator: the maker address, send wants to invoke this method representing for _creator
_underlyingAmount: indicating how many want() tokens should be sent from seller to contract for the seller to deliver successfully, apparently want() token is of type ERC20
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _tokenIds into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```



### 3.2 underlyingAssets(uint _orderId)
```
return: uint, indicating seller should send underlyingAssets(uint _orderId) amount of want() token if he wants to obtain _deliveryPrice amount of margin() token
```


## 4. Forward1155 interfaces

#### 4.1 createOrderFor(...)

Interface detail:
```
function createOrderFor(
    address _creator,
    uint[] memory _ids,
    uint[] memory _amounts,
    // uint _orderValidPeriod,
    // uint _deliveryStart,
    // uint _deliveryPeriod,
    uint[] memory _times,
    // uint _deliveryPrice, 
    // uint _buyerMargin,
    // uint _sellerMargin,
    uint[] memory _prices,
    address[] memory _takerWhiteList,
    bool _deposit,
    bool _isSeller
)
```

parameter explanation:

```
_creator: the maker address, send wants to invoke this method representing for _creator
_ids: array of tokenId, indicating what are the underlying assets, should be array of token ids from want() token of type ERC1155
_amounts: amounts of the above _ids array
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _ids into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```


### 4.2 underlyingAssets(uint _orderId)
```
return: (uint[] ids, uint[] amounts), indicating seller should send amounts of ids tokens if he wants to obtain _deliveryPrice amount of margin() token
```

## 5. ForwardEtherRouter

Should only be considered as useful when the margin is weth and user wants to use ether to create order, takeOrder, deliver order for all Forward20, Forward721, Forward1155 forward contracts.

TODO:

## 6. BaseFactoryUpgradeable

If there is no pool with specific underlying asset and margin token selected by user, then the user needs to create a new pool.

Interfact detail,
```
function deployPool(
        address _asset,
        uint _assetType,
        address _margin
    ) external virtual
```

parameter explanation:

```
_asset: the underlying asset designated by user
_assettype: if the _asset is erc20, value should be 20. If the _asset is erc721, value should be 721. If the _asset is erc1155, value should be 1155.
_margin: margin token designated by user, should be erc20, ether(or address(0) unsupported), weth is supported.
```

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
    - [1.5.10 getOrder(uint _orderId)](#1510-getorderuint-_orderid)
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
  - [5.1 createOrder20For](#51-createorder20for)
  - [5.2 createOrder721For](#52-createorder721for)
  - [5.3 createOrder1155For](#53-createorder1155for)
  - [5.4 takeOrderFor](#54-takeorderfor)
  - [5.5 deliverFor](#55-deliverfor)
  - [5.6 settle and cancelOrder](#56-settle-and-cancelorder)
- [6. BaseFactoryUpgradeable](#6-basefactoryupgradeable)
- [7. Special Cases in Eth.Mainnet](#7-special-cases-in-ethmainnet)
  - [7.1 CryptoPunks](#71-cryptopunks)
  - [7.2 kitties](#72-kitties)
  - [7.3 voxels & makersTokenV2](#73-voxels--makerstokenv2)

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

#### 1.5.10 getOrder(uint _orderId)
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

### 5.1 createOrder20For


Interface detail:
```
function createOrder20For(
    address _forward20,
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
_forward20: which forward20 contract is being invoked
_creator: the maker address, send wants to invoke this method representing for _creator
_underlyingAmount: indicating how many want() tokens should be sent from seller to contract for the seller to deliver successfully, apparently want() token is of type ERC20
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _tokenIds into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```
Note if `_deposit` and `_isSeller` are both `true`, meaning:

- step1. msg.sender wants to deposit _forward20's underlyingAmount of underlying asset into _forward20 contract directly
- step2. _forward20's margin token is weth, yet since he deposit underlying asset directly, no need to charge margin, so msg.value should be `0`

Then `msg.sender` is required to approve max amount of underlying asset to router conract since he marked `_deposit` and `_isSeller` as true.

However, in most cases, `_deposit` is `false`, meaning:
- case1 `_isSeller` = `true`: msg.sender needs to stake weth margin, he should set `msg.value` as his required margin amount (`sellerMargin`) as seller role in tx.
- case2 `_isSeller` = `false`: msg.sender also needs to stake weth margin, he should set `msg.value` as his required margin amount(`buyerMargin`) as buyer role in tx.


### 5.2 createOrder721For

Interface detail:
```
function createOrder721For(
    address _forward721,
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
_forward721: which forward721 contract is being invoked
_creator: the maker address, send wants to invoke this method representing for _creator
_tokenIds: array of tokenId, indicating what are the underlying assets, should be array of token ids from want() token of type ERC721
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _tokenIds into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```
Note if `_deposit` and `_isSeller` are both `true`, meaning:

- step1. msg.sender wants to deposit _forward721's underlyingAmount of underlying asset into _forward721 contract directly
- step2. _forward721's margin token is weth, yet since he deposit underlying asset directly, no need to charge margin, so msg.value should be `0`

Then `msg.sender` is required to approve _tokenIds underlying asset to router conract since he marked `_deposit` and `_isSeller` as true.

However, in most cases, `_deposit` is `false`, meaning:
- case1 `_isSeller` = `true`: msg.sender needs to stake weth margin, he should set `msg.value` as his required margin amount (`sellerMargin`) as seller role in tx.
- case2 `_isSeller` = `false`: msg.sender also needs to stake weth margin, he should set `msg.value` as his required margin amount(`buyerMargin`) as buyer role in tx.

### 5.3 createOrder1155For


Interface detail:
```
function createOrder1155For(
    address _forward1155,
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
_forward1155: which forward1155 contract is being invoked
_creator: the maker address, send wants to invoke this method representing for _creator
_ids: array of tokenId, indicating what are the underlying assets, should be array of token ids from want() token of type ERC1155
_amounts: amounts of the above _ids array
_times: should be [_orderValidPeriod, _deliveryStart, _deliveryPeriod], unit of second
_prices: should be [_deliveryPrice, _buyerMargin, _sellerMargin]
_takerWhiteList: should be specific addresses who the maker expects to take this order
_deposit: if _creator is seller and he wants to deposit _ids into contract directly or if _creator is buyer and he wants to deposit _deliveryPrice amount of margin into contract now, mark as true
_isSeller: if _creator is this order's seller
```

Note if `_deposit` and `_isSeller` are both `true`, meaning:

- step1. msg.sender wants to deposit _forward1155's underlyingAmount of underlying asset into _forward1155 contract directly
- step2. _forward1155's margin token is weth, yet since he deposit underlying asset directly, no need to charge margin, so msg.value should be `0`

Then `msg.sender` is required to approve _tokenIds underlying asset to router conract since he marked `_deposit` and `_isSeller` as true.

However, in most cases, `_deposit` is `false`, meaning:
- case1 `_isSeller` = `true`: msg.sender needs to stake weth margin, he should set `msg.value` as his required margin amount (`sellerMargin`) as seller role in tx.
- case2 `_isSeller` = `false`: msg.sender also needs to stake weth margin, he should set `msg.value` as his required margin amount(`buyerMargin`) as buyer role in tx.


### 5.4 takeOrderFor

Interfact detail,
```
function takeOrderFor(
        address _forward,
        address _taker,
        uint _orderId
    ) external payable
```

parameter explanation:
```
_forward: can be any type of forward contract
_taker: who the sender would like represent for to take _orderId's forward order
_orderId: which order should be taken
```

Normally speaking, _taker would be the same as msg.sender. However, when the forward contract's margin is weth and the `_taker` would like to choose ether directly as weth, then we provide the ForwardEtherRouter contract to help taker wrap their ether into weth and take `_orderId`'s order for them.

### 5.5 deliverFor

This method should be invokded only if :
- condition1: margin is weth for `_forward` contract, yet `msg.sender` wants to use ether directly.
- condition2: `deliverer` is buyer. Seller should invoke `_forward.deliverFor` method directly, which does not invoke ether transfer.

Interfact detail,
```
function deliverFor(
        address _forward,
        address _deliverer,
        uint _orderId
    ) external payable
```

parameter explanation:
```
_forward: can be any type of forward contract
_deliverer: who the sender would like represent for to deliver _orderId's forward order
_orderId: which order should be delivered
```

### 5.6 settle and cancelOrder
These two methods can be applied to any forward contract and invoked by anyone.

Interfact detail,
```
function settle(
        address _forward,
        uint _orderId
    ) external 

function cancelOrder(
        address _forward,
        uint _orderId
    ) external payable
```

parameter explanation:
```
_forward: can be any type of forward contract
_orderId: which order should be settled or canceled
```

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
_margin: margin token designated by user, should be erc20(ether or address(0) unsupported), weth is supported.
```

## 7. Special Cases in Eth.Mainnet

For address comparason, make sure to checksum the address before comparason is conducted.

### 7.1 CryptoPunks

- address: `0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB`
- abi file location: 
- changed methods:
  - approve:
    - replaced by interface:
    - param explanation:
  


### 7.2 kitties

- address: `0x06012c8cf97BEaD5deAe237070F9587f8E7A266d`
- abi file location: 
- changed methods:
  - approve:
    - replaced by interface:
    - param explanation:
  
### 7.3 voxels & makersTokenV2

- project: voxels
  - address: `0x79986aF15539de2db9A5086382daEdA917A9CF0C`
  - abi file location: 
  - changed methods:
    - approve:
      - replaced by interface:
      - param explanation:
- project: makersTokenV2
  - address: `0x2A46f2fFD99e19a89476E2f62270e0a35bBf0756`
  - abi file location: 
  - changed methods:
    - approve:
      - replaced by interface:
      - param explanation:
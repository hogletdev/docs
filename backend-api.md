<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
<!-- **Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)* -->

- [Rpc Request](#rpc-request)
    - [1. ping](#1-ping)
    - [2. get_forward_orders](#2-get_forward_orders)
    - [3. get_default_tokens_by_types](#3-get_default_tokens_by_types)
    - [4. get_tokens_info_by_addr](#4-get_tokens_info_by_addr)
    - [5. get_supported_margins_by_assets](#5-get_supported_margins_by_assets)
    - [6. user_request_auth](#6-user_request_auth)
    - [7. user_verify_auth](#7-user_verify_auth)
    - [8. set_user_forward_orders](#8-set_user_forward_orders)
    - [9. get_user_forward_orders](#9-get_user_forward_orders)
    - [10. del_user_forward_orders](#10-del_user_forward_orders)
    - [11. upload_user_profile](#11-upload_user_profile)
    - [12. get_user_profile](#12-get_user_profile)
    - [13. get_tokens_detail_by_addr_id](#13-get_tokens_detail_by_addr_id)
- [Rest Request](#rest-request)
    - [1. ping](#1-ping-1)
    - [2. get_forward_orders](#2-get_forward_orders-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Hoglet backend Service

## Rpc Request

Accept: application/json

Content-Type: application/json

All rpc request should be sent to `https://api.hoglet.io/rpc` through "POST" method.

#### 1. ping

Test Rpc working

Request Body:

```json
{
    "method": "ping",
    "id": 1
}
```

Response:

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": "pong"
}
```

#### 2. get_forward_orders

Get public on-chain forward contract orders

Request Body

```json
{
    "method": "get_forward_orders", // method name
    "chain_id": 4, // rinkeby
    "filter": {
        "order_state": ["Expired", "Settled"],
        "order_type": [20, 721],
        "ids": [6, 5, 4]
    },
    "page_number": 1, // or page index
    "page_size": 20,
    "id": 10
}
```

About Request parameters:

| Param              | notion                                                                                                                           |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| method             | "get_forward_orders"                                                                                                             |
| chain_id           | eth mainnet = 1, rinkeby test net = 4                                                                                            |
| filter.order_state | string array, only support "Active", "Filled", "Delivery", "Expired" and "Settled". order_state filter can be removed from filer |
| filter.order_type  | int array, only support 20, 721, 1155. order_type filter can be removed from filer                                               |
| filter.ids         | int array, should be the returned order.id field, which is the id stored in db                                                   |
| page_number        | which page of orders we would like to fetch                                                                                      |
| page_size          | how many orders are contained in one page                                                                                        |
| id                 | can be any int to avoid concurrent issue                                                                                         |

About filter.order_state meaning:

| order_state | notion                                                                   |
| ----------- | ------------------------------------------------------------------------ |
| Active      | order made on-chain yet not taked                                        |
| Filled      | order taked on-chain yet not should be exercise/delivered                |
| Delivery    | order should be delivered by both seller and buyer                       |
| Expired     | buyer not deliver or seller not deliver after the expire start timestamp |
| Settled     | no mather who delivered and not delivered, the order has been liquidated |

Response:

```json
{
    "code": 200,
    "desc": "OK",
    "id": 2,
    "result": {
        "total_forward_orders": 3,
        "forward_orders": [
            // array
            {
                "id": 6,
                "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "order_type": 721,
                "order_id": 5,
                "created_time": 1633261533,
                "order_valid_period": 1633261713,
                "valid_till": 1633261713,
                "deliver_price": "100000000000",
                "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "deliver_start": 1633261848,
                "deliver_period": 180,
                "expire_start": 1633262028,
                "buyer": {
                    "addr": "0x01be1e724a00fF2C34BDE31d56835C5d438A34DA",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "seller": {
                    "addr": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "order_state": 6,
                "order_state_desc": "Settled",
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["5", "10005"],
                    "token_ids_url": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0005.png",
                        ""
                    ]
                },
                "order_created": true
            },
            {
                "id": 5,
                "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "order_type": 721,
                "order_id": 4,
                "created_time": 1633259957,
                "order_valid_period": 1633260137,
                "valid_till": 1633260137,
                "deliver_price": "100000000000",
                "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "deliver_start": 1633260287,
                "deliver_period": 180,
                "expire_start": 1633260467,
                "buyer": {
                    "addr": "0x01be1e724a00fF2C34BDE31d56835C5d438A34DA",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "seller": {
                    "addr": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "order_state": 6,
                "order_state_desc": "Settled",
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["4", "10004"],
                    "token_ids_uri": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0004.png",
                        ""
                    ]
                },
                "order_created": true
            },
            {
                "id": 4,
                "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "order_type": 721,
                "order_id": 3,
                "created_time": 1633259327,
                "order_valid_period": 1633259507,
                "valid_till": 1633259507,
                "deliver_price": "100000000000",
                "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "deliver_start": 1633259657,
                "deliver_period": 180,
                "expire_start": 1633259837,
                "buyer": {
                    "addr": "0x01be1e724a00fF2C34BDE31d56835C5d438A34DA",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": false
                },
                "seller": {
                    "addr": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": false
                },
                "order_state": 5,
                "order_state_desc": "Expired",
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["4", "10004"],
                    "token_ids_url": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0004.png",
                        ""
                    ]
                },
                "order_created": true
            }
        ]
    }
}
```

| key                               | meaning                                                                                                                                                                                                              |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| total_forward_orders              | how many forward orders are returned                                                                                                                                                                                 |
| forawrd_orders                    | is an array                                                                                                                                                                                                          |
| forawrd_orders.id                 | unique id of this order, should be carefully used when save off-chain orders                                                                                                                                         |
| forawrd_orders.pool_addr          | from which forward contract this order was created                                                                                                                                                                   |
| forawrd_orders.order_type         | int type, can only be 20/721/1155                                                                                                                                                                                    |
| forawrd_orders.create_time        | block chain timestamp                                                                                                                                                                                                |
| forawrd_orders.order_valid_period | unit is second, once the order is created, the order will be dead and can only be canceled by anyone if nobody takes that order after this duration                                                                  |
| forawrd_orders.valid_till         | create_time + order_valid_period                                                                                                                                                                                     |
| forawrd_orders.deliver_price      | if value is 1e18 and delivery token is weth, then the price is 1 weth or 1 ether                                                                                                                                     |
| forawrd_orders.deliver_token      | the buyer should send deliver_price amount of deliver_token to pool_addr contract by invoking "deliverFor" method during the exercising/delivering period/duration.                                                  |
| forawrd_orders.deliver_start      | after which time, the buyer should send deliver_price amount of deliver_token and the seller should send the underlying assets into forward_contract to complete exercise operation by invoking "deliveryFor" method |
| forawrd_orders.deliver_period     | how long the exercise can be conducted, unit is second                                                                                                                                                               |
| forawrd_orders.expire_start       | deliver_start + deliver_period                                                                                                                                                                                       |
| forawrd_orders.buyer.addr         | which address agrees to buy underlyingAsset during exercising period                                                                                                                                                 |
| forawrd_orders.buyer.margin       | how many deliver_token the buyer should stake into pool_addr forward contract                                                                                                                                        |
| forawrd_orders.buyer.share        | how many shares the buyer have coming from his staked margin, (forward contract ready to stake margins into farming pool to help forward user earn passive income.                                                   |
| forward_orders.buyer.delivered    | if the buyer has kept his promise and send deliver_price of deliver_token into forward contract                                                                                                                      |
| forawrd_orders.seller.addr        | same as buyer.addr                                                                                                                                                                                                   |
| forawrd_orders.seller.margin      | same as buyer.margin                                                                                                                                                                                                 |
| forawrd_orders.seller.share       | same as buyer.share                                                                                                                                                                                                  |
| forawrd_orders.seller.delivered   | same as buyer.delivered                                                                                                                                                                                              |
| forawrd_orders.order_state        | same as the stored on chain data                                                                                                                                                                                     |
| forawrd_orders.order_state_desc   | readable meaning for human following order_state value                                                                                                                                                               |
| forawrd_orders.asset_addr         | this is the underlying asset token address, can be erc20, erc721 or erc1155                                                                                                                                          |
| forawrd_orders.asset_info         | Carefully Take this into consideration                                                                                                                                                                               |
| forawrd_orders.order_created      | Whether if this order is on-chain                                                                                                                                                                                    |

When forward_orders.asset_addr or forward_orders.order_type is of type 20, forawrd_orders.asset_info is

```json
{
    "amount": "1234556"
}
```

When forward_orders.asset_addr or forward_orders.order_type is of type 721, forawrd_orders.asset_info is

```json
{
    "token_ids": ["5", "10005"],
    "token_ids_uri": [
        "https://www.larvalabs.com/public/images/cryptopunks/punk0005.png",
        ""
    ]
}
```

When forward_orders.asset_addr or forward_orders.order_type is of type 1155, forawrd_orders.asset_info is

```json
{
    "token_ids": ["5", "10005"],
    "token_ids_uri": [
        "https://www.larvalabs.com/public/images/cryptopunks/punk0005.png",
        ""
    ],
    "amounts": ["100", "200"]
}
```

#### 3. get_default_tokens_by_types

Get default token info details by token types

Request Body

```json
{
    "method": "get_default_tokens_by_types",
    "chain_id": 4,
    "token_types": [721],
    "page_number": 1,
    "page_size": 1000,
    "id": 1
}
```

Response:

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": {
        "total_default_tokens": 3,
        "default_tokens": [
            {
                "name": "Maker",
                "symbol": "MKR",
                "decimals": 18,
                "type": 20,
                "address": "0xF9bA5210F91D0474bd1e1DcDAeC4C58E359AaD85",
                "ChainId": 4,
                "logo_uri": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xF9bA5210F91D0474bd1e1DcDAeC4C58E359AaD85/logo.png"
            },
            {
                "name": "Dai Stablecoin",
                "symbol": "DAI",
                "decimals": 18,
                "type": 20,
                "address": "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735",
                "ChainId": 4,
                "logo_uri": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735/logo.png"
            },
            {
                "name": "Wrapped Ether",
                "symbol": "WETH",
                "decimals": 18,
                "type": 20,
                "address": "0xc778417E063141139Fce010982780140Aa0cD5Ab",
                "ChainId": 4,
                "logo_uri": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xc778417E063141139Fce010982780140Aa0cD5Ab/logo.png"
            }
        ]
    }
}
```

#### 4. get_tokens_info_by_addr

Get token info details by token address.

Provided by backend (including both stored and fetched result from other platforms like nftscan, opensea)
Request

```json
{
    "method": "get_tokens_info_by_addr",
    "chain_id": 4,
    "token_addr": [
        "0xc778417E063141139Fce010982780140Aa0cD5Ab",
        "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735"
    ],
    "id": 1
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": {
        "total_tokens": 2,
        "missed_tokens": 0,
        "token_info": {
            "0xc778417E063141139Fce010982780140Aa0cD5Ab": {
                "name": "Wrapped Ether",
                "symbol": "WETH",
                "decimals": 18,
                "type": 20,
                "address": "0xc778417E063141139Fce010982780140Aa0cD5Ab",
                "ChainId": 4,
                "logo_uri": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xc778417E063141139Fce010982780140Aa0cD5Ab/logo.png"
            },
            "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735": {
                "name": "Dai Stablecoin",
                "symbol": "DAI",
                "decimals": 18,
                "type": 20,
                "address": "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735",
                "ChainId": 4,
                "logo_uri": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735/logo.png"
            }
        }
    }
}
```

#### 5. get_supported_margins_by_assets

Here, "supported" means the specific forward contract has been deployed on-chain with a certain margin token and asset contract.

Once user has confirmed his underlying asset behind the delivery token and delivery price, this interface will return which pools have been deployed on chain for users to choose, if not choose one pool from the provided, the user needs to deploy a new pool corresponding with a new margin token.

Although the user has to deploy a new pool, he/she will only be charged approximately 500k gas limit to deploy the pool. It's very user-friendly because we apply the beacon proxy for the forward contract implementation for diffenent underlying assets including ERC20, ERc721 and ERC1155, which means user will only need to create an empty storage contract. The logic implementation will be deployed and managed (mainly upgraded in case there exist bugs) by hoglet.io team currently. And the management of logic implementation will be transferred to the governance contract once the hoglet token is issued so that all the hoglet token holders will be able to upgrade the logic implementation, or set the forward operation fee, which we hope will be rewarded to the hoglet token holders.

Request

```json
{
    "method": "get_supported_margins_by_assets",
    "chain_id": 4,
    "token_addr": ["0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7"],
    "id": 1
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": {
        "total_pools": 2,
        "asset_to_pools": {
            "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7": {
                "asset_info": {
                    "name": "Test",
                    "symbol": "Symbol",
                    "decimals": 18,
                    "type": 20,
                    "address": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                    "ChainId": 4,
                    "logo_uri": "logo_uri"
                },
                "pools": [
                    {
                        "chain_id": 4,
                        "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                        "pool_type": 721,
                        "factory_addr": "0x58192216C8c1f446326048BB7e157Ca8699D770d",
                        "pool_index": 0,
                        "margin": {
                            "name": "Test",
                            "symbol": "Symbol",
                            "decimals": 18,
                            "type": 20,
                            "address": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                            "ChainId": 4,
                            "logo_uri": "logo_uri"
                        },
                        "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7"
                    },
                    {
                        "chain_id": 4,
                        "pool_addr": "0x8E90A6cdd252c0bC064AeAf2530C53D3e2e8181C",
                        "pool_type": 721,
                        "factory_addr": "0x58192216C8c1f446326048BB7e157Ca8699D770d",
                        "pool_index": 1,
                        "margin": {
                            "name": "Test",
                            "symbol": "Symbol",
                            "decimals": 18,
                            "type": 20,
                            "address": "0x8E90A6cdd252c0bC064AeAf2530C53D3e2e8181C",
                            "ChainId": 4,
                            "logo_uri": "logo_uri"
                        },
                        "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7"
                    }
                ],
                "pools_count": 2
            }
        }
    }
}
```

#### 6. user_request_auth

Get auth token for user to sign, work with 7th interface to confirm user's login operation

Request

```json
{
    "method": "user_request_auth",
    "user": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
    "id": 1
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": "token:mS6C3KOejRFU7E6789vIVEJJzZzVz-qqgp3nZr81mfcSTEcUxSZo3F_1_Dh5bTZ-asSgnHtSr065p9wy-RJ8XccCcr0fOC6z-zw2hlVy0QRioNmXiUV7PkkSIctkUcWHadDEQpX7x7b2eFGImAxlLZG0Bz0="
}
```

#### 7. user_verify_auth

Post the signature to the backend, then backend will confirm it's user who is currently operating the off-chain data(mainly saved/updated off-chain forwards)

Request

```json
{
    "method": "user_verify_auth",
    "user": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
    "signature": "0xec69068d68e3d51a4dd41f9d5a7ecf4b10a6e0d048f5568b79c0a2ef4d851d9f2d52a2350ce955498b65f7f29e4f455f2dbd260a97fd845a655af85c3f87450d1c",
    "id": 1
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": "Verify success, token effective for 0x8A0532F75D6BAcfcA977ce74025cfbf876278697 to retrive personal data"
}
```

#### 8. set_user_forward_orders

User request to save his off-chain forward orders

Request

```json
{
    "method": "set_user_forward_orders",
    "user": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
    "orders": [
        {
            "id": 0,
            "chain_id": 4,
            "pool_addr": "",
            "asset": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
            "order_type": 721,
            "valid_till": 1633260087,
            "deliver_start": 1633260287,
            "deliver_period": 100,
            "expire_start": 1633260387,
            "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
            "deliver_price": "234",
            "buyer_margin": "345",
            "seller_margin": "456",
            "buyer_addr": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
            "seller_addr": "0x00",
            "seller_addr": "",
            "asset_info": {
                "amount": "1234",
                "token_ids": ["1", "2"],
                "amounts": ["100", "200"]
            },
            "digest": "bytes32()",
            "direction": "buy",
            "maker_sig": "",
            "salt": "random_bytes32"
        }
    ]
}
```

| order_type | asset_info cotent                                                          |
| ---------- | -------------------------------------------------------------------------- |
| 20         | should contain "amount" field, "amounts" and "token_ids" won't be absorbed |
| 721        | should contain "token_ids" field, "amounts" and "amount" won't be absorbed |
| 1155       | should contain "token_ids" and "amount" fields, "amount" won't be absorbed |

It should be noted that user address who is saving the orders should be buyer or seller from any of the updated orders

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 0,
    "result": ""
}
```

#### 9. get_user_forward_orders

User request to fetch his off-chain forward orders

Request

```json
{
    "method": "get_user_forward_orders",
    "user": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
    "chain_id": 4,
    "filter": {
        "order_state": ["Settled"],
        "order_type": [20, 721],
        "ids": [11, 10, 6, 5]
    },
    "page_number": 1,
    "page_size": 10,
    "id": 1
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 1,
    "result": {
        "total_forward_orders": 4,
        "forward_orders": [
            {
                "id": 11,
                "pool_addr": "0x0000000000000000000000000000000000000000",
                "order_type": 721,
                "order_id": -1,
                "deliver_price": "234",
                "deliver_token": "0x0000000000000000000000000000000000000000",
                "deliver_start": 1633260287,
                "deliver_period": 100,
                "expire_start": 1633260387,
                "buyer": {
                    "addr": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
                    "margin": "345",
                    "share": "",
                    "delivered": false
                },
                "seller": {
                    "addr": "0x0000000000000000000000000000000000000000",
                    "margin": "456",
                    "share": "",
                    "delivered": false
                },
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["1", "2"],
                    "token_ids_uri": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0001.png",
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0002.png"
                    ]
                },
                "order_created": false
            },
            {
                "id": 10,
                "pool_addr": "0x0000000000000000000000000000000000000000",
                "order_type": 721,
                "order_id": -1,
                "deliver_price": "234",
                "deliver_token": "0x0000000000000000000000000000000000000000",
                "deliver_start": 1633260287,
                "deliver_period": 100,
                "expire_start": 1633260387,
                "buyer": {
                    "addr": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
                    "margin": "345",
                    "share": "",
                    "delivered": false
                },
                "seller": {
                    "addr": "0x0000000000000000000000000000000000000000",
                    "margin": "456",
                    "share": "",
                    "delivered": false
                },
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["1", "2"],
                    "token_ids_uri": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0001.png",
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0002.png"
                    ]
                },
                "order_created": false
            },
            {
                "id": 6,
                "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "order_type": 721,
                "order_id": 5,
                "created_time": 1633261533,
                "order_valid_period": 180,
                "valid_till": 1633261713,
                "deliver_price": "100000000000",
                "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "deliver_start": 1633261848,
                "deliver_period": 180,
                "expire_start": 1633262028,
                "buyer": {
                    "addr": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "seller": {
                    "addr": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "order_state": 6,
                "order_state_desc": "Settled",
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["5", "10005"],
                    "token_ids_uri": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0005.png",
                        ""
                    ]
                },
                "order_created": true
            },
            {
                "id": 5,
                "pool_addr": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "order_type": 721,
                "order_id": 4,
                "created_time": 1633259957,
                "order_valid_period": 180,
                "valid_till": 1633260137,
                "deliver_price": "100000000000",
                "deliver_token": "0xC99c1D6d78C7bb75B41517d6b82F35248b06f684",
                "deliver_start": 1633260287,
                "deliver_period": 180,
                "expire_start": 1633260467,
                "buyer": {
                    "addr": "0x8A0532F75D6BAcfcA977ce74025cfbf876278697",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "seller": {
                    "addr": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
                    "margin": "10000000000",
                    "share": "10000000000",
                    "delivered": true
                },
                "order_state": 6,
                "order_state_desc": "Settled",
                "asset_addr": "0xBc4595B1487E4bA99cd4A61258b2a3bE1469D4B7",
                "asset_info": {
                    "token_ids": ["4", "10004"],
                    "token_ids_uri": [
                        "https://www.larvalabs.com/public/images/cryptopunks/punk0004.png",
                        ""
                    ]
                },
                "order_created": true
            }
        ]
    }
}
```

Response will contain both on-chain forward orders and off-chains

#### 10. del_user_forward_orders

User request to delete his off-chain forward orders

Request

```json
{
    "method": "del_user_forward_orders",
    "user": "0xf2Ac84D916E28aEB434b67f38cd0e481172dD029",
    "orders": [11, 7, 8, 9]
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 0,
    "result": ""
}
```

#### 11. upload_user_profile

Require auth token to verify user's identity

User request to uplaod his off-chain user profile
---|---
key | value
---|---
method | upload_user_profile
username | "username"
user_addr | "0xf2\*\*\*48"
email | test1@gmail.com
bio | Hi, openland
avatar | cat.jpg/dog.png

#### 12. get_user_profile

Request to get nft info by nft address and token id

---|---
key | value
---|---
method | get_user_profile
user_addr | "0xf2\*\*\*48"

#### 13. get_tokens_detail_by_addr_id

Require auth token to verify user's identity

Request

```json
{
    "method": "get_tokens_detail_by_addr_id",
    "chain_id": 4,
    "addr_to_ids": {
        "0x308D1634c6216BBd5AD51a16de98A7B305FBf38a": [1, 2]
    }
}
```

Response

```json
{
    "code": 200,
    "desc": "OK",
    "id": 0,
    "result": {
        "token_ids_detail": {
            "0x308D1634c6216BBd5AD51a16de98A7B305FBf38a": {
                "basic_token_info": {
                    "name": "CryptoPunks",
                    "symbol": "PUNK",
                    "decimals": 0,
                    "type": 721,
                    "address": "0x308D1634c6216BBd5AD51a16de98A7B305FBf38a",
                    "ChainId": 4,
                    "logo_uri": "https://lh3.googleusercontent.com/BdxvLseXcfl57BiuQcQYdJ64v-aI8din7WPk0Pgo3qQFhAUH-B6i-dCqqc_mCkRIzULmwzwecnohLhrcH8A9mpWIZqA7ygc52Sr81hE=s120"
                },
                "token_id_detail": {
                    "1": {
                        "uri": "https://www.larvalabs.com/public/images/cryptopunks/punk0001.png",
                        "nftscan": "https://nftscan.com/detail/NSD1A1169FFBB6DD22",
                        "opensea": ""
                    },
                    "2": {
                        "uri": "https://www.larvalabs.com/public/images/cryptopunks/punk0002.png",
                        "nftscan": "https://nftscan.com/detail/NS75D1ADF30FFA8F06",
                        "opensea": ""
                    }
                }
            }
        },
        "total_ids": 2,
        "missed_ids": 0
    }
}
```

## Rest Request

#### 1. ping

Test Rest working

```
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://api.hoglet.io/rest/v1/ping
```

#### 2. get_forward_orders

Get public on-chain forward contract orders

https://api.hoglet.io/rest/v1/forward/orders/{chain_id:int}/{page_number:int}/{page_size:int}

```markdown
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://api.hoglet.io/rest/v1/forward/orders/4/1/10
```

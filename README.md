# CrowdFund

A decentralized **ERC20 crowdfunding smart contract** built with Solidity.

## Features

* Create crowdfunding campaigns
* Set funding goals and campaign duration
* Pledge ERC20 tokens
* Withdraw pledged tokens before the deadline
* Claim funds when the goal is reached
* Refund contributors when the goal is not reached
* Cancel campaigns before they start

## How It Works

```text
Create Campaign
       ↓
    Pledge
       ↓
Campaign Ends
   ↙       ↘
Success    Failed
   ↓          ↓
 Claim      Refund
```

## Tech Stack

* Solidity `^0.8.31`
* ERC20
* Foundry

## Main Functions

| Function     | Description                        |
| ------------ | ---------------------------------- |
| `launch()`   | Create a campaign                  |
| `pledge()`   | Contribute ERC20 tokens            |
| `unpledge()` | Withdraw a contribution            |
| `claim()`    | Claim successful campaign funds    |
| `refund()`   | Refund contributors                |
| `cancel()`   | Cancel a campaign before it starts |

## License

MIT License

> Educational project for learning Solidity and smart contract development.

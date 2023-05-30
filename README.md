# blockchain-supply-chain
Supply chain in blockchain based on 2 smart contracts ( Role and SupplyChain ).

There are 3 types of users, created at the init of the SupplyChain smart contract:
1. Creator
2. Distribuitor
3. Client

Creators can create items in the network.
Distribuitors can buy items from creators/ other distribuitors.
Clients can buy items from distribuitors.

On each tx corresponding amount of ETH is subtracted from the buyer and given to the owner.

This project correctness is validated trough tests for each contract.

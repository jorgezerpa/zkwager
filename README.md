# ZKwager: Web3 bets for your videogames

ZKwager is a "Smart contracts as a Service" project that helps game developers to implement transparent and provable blockchain bets in their games, with no need to write their own smart contracts. 

## How does this work?
Zkwager provides **Easy to plugin** functionalities for implement web3 bets in videogames. Developers can just take their existant game and connect it with the contracts they need, in function of their existant game logic. 

## Main features
- **Multiplatform**: ZKwager provides only the smart contracts. This means that developers can interact with such functionalities from any platform as long as that platform allows interaction with Starknet (for instance: starknet.js for web games or starknet.unity for unity engine). 
- **Efficient and Scalable**: Thanks to Starknet's L2 technology, ZKwager offers a fast, secure and scalable solutions for web3 bettings.
- **No third parties**: The bets are managed directly between the wallets (players) and the smart contract, with no need to a third party to manage the bet.   

## What functionalities provides ZKwager?
- **Simple bet mode**: The simplier way to add web3 bets in your game. In this case our contracts will have the only task of hold the bets and distribute the prizes to the wallets once the game is finished. All the logic to determine the winner runs off-chain by the game logic. 
- **Counter mode**: If you want to go further with the provability of your games, you can use some "Counter" contracts, which will be in charge of count important aspect of the game, for instance: number of coins collected by each player, number of kills in a shooting game, number of matches won, etc. And when the game is finished, the logic to determine the winners will be made on-chain based on the counters results.
- **Fixed goal mode**: You can set a goal for your bet like "the first player to achieve X amount of points" and when that goal is achieved, the prizes will be inmediatly transfered to the winner account.

Of course you can set different logic to distribute the prizes like "X amount to 1st position, X amount to 2nd position"... or something like "X amount to the first 3 players... and so on. 


## Contributors

- [jorgezerpa](https://github.com/jorgezerpa)


## Want to Contribute?
We are still developing a basic MVP of the project. We hope to start accepting contributions very soon. Stay tooned!


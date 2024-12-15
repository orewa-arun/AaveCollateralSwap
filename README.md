# Problem Description #
We have deposited AAVE tokens and using it as collateral,we have borrowed DAI.Now we see that the aave token price is taking a dip and another token's growth
like BAT looks promising.You fear the liquidation of your collateral and losing monetary value,so you decide to swap your collateral (AAVE-->BAT).

You think of paying back the borrowed DAI and withdrawing AAVE so as to swap it on a DEX like Uniswap,but unfortunately your DAI has been locked into 
various other investments.

You may think you are stuck and probably get ready to surrender to this so called "fate",until you come to know of one of the greatest tools in 
defi : "FLASH LOANS!".

# Steps used in proposed solution #
## Collateral Swap ##
1)Execute flash loan to borrow the DAI required to payback the loan.(using aave V2 protocol)\
### In the flash loan execution function: ###
2.1)We repay the DAI loan along with interests and get back the AAVE collateral tokens.\
2.2)Withdraw AAVE tokens and swap them for BAT in uniswap.\
2.3)Use that BAT tokens to get a loan of DAI.\
2.4)The swapped DAI + premium fee is consumed again by the flashloan.\
2.5)We have now swaped the collateral from AAVE to BAT.
  
Note:We have assumed that the risk factor in the aave loan allows the borrow limit of DAI when we switch collateral in (2.3).

# Comments #
* I was unable to write tests for the contract because the test token addresses were different in uniswap and in aave,as a result i was unable to swap.
* The contract might work in real world though,but definitely without using the oracle values,the contract becomes highly ineffective.
* If we use the oracle values,only then we will be able to make effective and risk assessed trade in the world of defi,in that way we would be able to
create not only a DApp but also a magnificient protocol on defi that can be used to create trade bots in the defi world.
* I have refrained from broadening the scope of this assessment problem,so i have not used any oracles.

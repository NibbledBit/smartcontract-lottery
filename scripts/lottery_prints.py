from brownie import Lottery, accounts, config, network
from web3 import Web3


def printStuff():
    account = accounts[0]
    lottery = Lottery.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        config["networks"][network.show_active()]["gbp_usd_price_feed"],
        {"from": account},
    )
    entrance_fee = lottery.getEntranceFee()
    print(f"Entrance fee: {entrance_fee}")
    gbpUsd = lottery.getGbpUsdPrice()
    print(f"GBP USD fee: {gbpUsd}")
    ethUsd = lottery.getEthUsdPrice()
    print(f"ETH USD fee: {ethUsd}")


def main():
    printStuff()

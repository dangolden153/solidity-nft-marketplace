const { assert, expect } = require("chai");
const { network, getNamedAccounts, deployments, ethers } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Nft Marketplace test", function () {
      let nftMarketplace, basicNft, deployer, player;
      const TOKEN_ID = 0
      const PRICE = ethers.utils.parseEther("0.1")

      beforeEach(async function () {
        //delpoy all contracts/
        //get contracts/
        //to have both deployer and player's account /
        //mint nft /
        //approve nft/
        deployer = (await getNamedAccounts()).deployer
       let accounts = await ethers.getSigners(); // could also do with getNamedAccounts
        player = accounts[1];
        await deployments.fixture(["all"]);
        nftMarketplace = await ethers.getContract("NftMarketplace");
        basicNft = await ethers.getContract("BasicNft");
        await basicNft.mintNft();
        await basicNft.approve(nftMarketplace.address, TOKEN_ID);
      });


      it("emits an event after listing an item", async function () {
        expect(await nftMarketplace.ListNftsItems(basicNft.address, TOKEN_ID, PRICE)).to.emit(
            "ItemListed"
        )
    })

      //should list and but nft
      it("should list and can buy nft", async function () {
        await nftMarketplace.ListNftsItems(basicNft.address, TOKEN_ID, PRICE);
        const playerConnectedNftMarketplace = nftMarketplace.connect(player);
        await playerConnectedNftMarketplace.BuyItem(basicNft.address, TOKEN_ID, {
          value: PRICE,
        });
        const isOwner = await basicNft.ownerOf(TOKEN_ID);
        const deployerProceeds = await nftMarketplace.getProceeds(deployer);
        assert(isOwner.toString() == player.address);
        assert(deployerProceeds.toString() == PRICE.toString());
      });



    });

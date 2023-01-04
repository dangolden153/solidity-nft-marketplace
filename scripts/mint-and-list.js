const { ethers } = require("hardhat")

const PRICE = ethers.utils.parseEther("0.1")

 async function mintAndListNft(){
const nftMarketplace = await ethers.getContract("NftMarketplace")
const basicNft = await ethers.getContract("BasicNft")
console.log("minting nft.....")

const mintNft = await basicNft.mintNft()
const mintNftTxReceipt = await mintNft.wait(1)
console.log("nft minted! .....")

const tokenId = mintNftTxReceipt.events[0].args.tokenId
console.log("approving nft.....")

const approvetx = await basicNft.approve(nftMarketplace.address, tokenId)
await approvetx.wait(1) 
console.log("listing nft to market place.....")

const listTx = await nftMarketplace.ListNftsItems(basicNft.address, tokenId, PRICE)
await listTx.wait(1)
console.log("listed nft to market place!.....")


}



mintAndListNft()
.then(()=> process.exit(0))
.catch(e=>{
    console.log(e)
    process.exit(1)
})
const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function ({getNamedAccounts, deployments}) {
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();
    let args = []


    log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    const basicNft = await deploy("BasicNft",{
        from : deployer,
        log:true,
        args: args,
        waitComfirmation: network.config.blockComfirmations
    })
    log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")



    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        log('verifying.....')
        verify(basicNft.address, args)
    }
}

module.exports.tags = ['all', 'basicNft']
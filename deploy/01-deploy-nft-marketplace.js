
const {network} = require('hardhat');
const { developmentChains } = require('../helper-hardhat-config');
const { verify } = require('../utils/verify');


module.exports = async function ({getNamedAccounts, deployments}){

    const {deployer} = await getNamedAccounts()
    const {log, deploy} =  deployments;
    let args = []


    log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    const nftMarketplace = await deploy("NftMarketplace",{ 
        from: deployer,
        log:true,
        args:args,
        waitConfirmations: network.config.blockConfirmations || 1
    })

    log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")


    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
      log('verifying......')
        verify(nftMarketplace.address, args)
    }
}

module.exports.tags = ['all', 'nftMarketplace']
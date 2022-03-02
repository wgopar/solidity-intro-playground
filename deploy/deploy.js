const fs = require('fs')

module.exports = async({
  getNamedAccounts,
  deployments,
  getChainId
}) => {

  const {deploy, log} = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = await getChainId()

  log("---- Deployment Starting ----")
  const MyToken = await deploy("MyTokenV2", {from: deployer, args: [deployer ,"MyTokenV2", "MTKN"], log: true})

  log("---- Contract Deployed to ${myToken.address}");
}


module.exports.tags = ['MyTokenV2'];

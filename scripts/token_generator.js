const hre = require("hardhat");
const fs = require("fs");


async function main() {

  let deploy_return = await deployments.fixture(['MyTokenV2']);

  const contract_address = deploy_return["MyTokenV2"]["address"];
  const myToken = await ethers.getContractFactory("MyTokenV2");
  const MyToken = await myToken.attach(contract_address);

  const accounts = await hre.ethers.getSigners()

  // mint 20 tokens, and output them locally to output/
  const num_mints = 20;
  for (let i = 0; i < num_mints; i++) {

    let signer = accounts[i];
    console.log(`----------------------MINTING ${i}----------------------`);
    console.log(`Minter ${i} address ${signer.address}`);
    tx = await MyToken.mint(signer.address);
    let receipt = await tx.wait(1);
    console.log(`Reciept: ${receipt}`);

    let rawtokenURI = await MyToken.tokenURI(i + 1);
    rawtokenURI = rawtokenURI.split(',')[1];
    console.log("\nRaw Token URI:\n" + rawtokenURI + "\n");

    let tokenURI= JSON.parse(Buffer.from(rawtokenURI, 'base64'));
    console.log("Decoded URI: \n" + JSON.stringify(tokenURI) + "\n");

    let imageURI = tokenURI["image"].split(',')[1];
    console.log("Image URI: \n" + imageURI + "\n");

    let imageURIDecoded = Buffer.from(imageURI, 'base64').toString();
    console.log("Decoded SVG Image: \n" + imageURIDecoded + "\n");

    try {
      fs.writeFileSync(`output/mint_${i}.svg`, imageURIDecoded)
      //file written successfully
    } catch (err) {
      console.error(err)
    }

  }
  console.log(`------------------------------------------------`);
  console.log(`---Calling to Generate SVG based on tokenID-----`);
  console.log(`------------------------------------------------`);

  // to get function return you have to make sure that it is 'view' funcion
  const value = await MyToken.fetchSVG(1);
  console.log('fetchSVG response is: ---> \n', value);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

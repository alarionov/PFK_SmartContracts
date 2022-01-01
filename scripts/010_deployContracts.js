async function getRawTx (wallet, data, to, value)
{
    const gasPrice = web3.utils.toWei('1', 'gwei');
    const gasAmount = 10000000;
    
    const tx = {
        from: wallet,
        data: data,
        nonce: NONCE,
        gas: gasAmount,
        gasPrice: gasPrice
    };
    
    if (typeof to !== "undefined")
    {
        tx.to = to;
    }
    
    if (typeof value !== "undefined")
    {
        tx.value = value;
    }
    
    return tx;
}

async function sendTransaction(rawTx, privateKey) 
{
    const signedTx = await web3.eth.accounts.signTransaction(rawTx, privateKey);
    const response = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    return response;
}

async function deployContract(wallet, privateKey, libraries, artifactsPath, args) 
{
    const metadataJson = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const metadata = linkLibraries(metadataJson, libraries);
    const contract = new web3.eth.Contract(metadata.abi);
    const params = {data: "0x" + metadata.data.bytecode.object};
    
    if (typeof(args) === "object")
    {
        Object.assign(params, { arguments: args }); 
    }

    const data = contract.deploy(params).encodeABI();
    const rawTx = await getRawTx(wallet, data);
    const response = await sendTransaction(rawTx, privateKey);
    return new web3.eth.Contract(metadata.abi, response.contractAddress);
}

const linkLibraries = (metadata, libraries) => {
    for (libName in libraries)
    {
        const placeholder = web3.utils.soliditySha3(`contracts/libraries/${libName}.sol:${libName}`).substr(2, 34);
        const address = libraries[libName].substr(2);
        metadata.data.bytecode.object = metadata.data.bytecode.object.replaceAll("__$"+placeholder+"$__", address);
    }

    return metadata;
};

let NONCE = 0;
(async () => {

    const libraries = JSON.parse(await remix.call('fileManager', 'getFile', "browser/deployed/libraries.json"));

    try {
        console.log("....................................");
        
        const myconf = JSON.parse(await remix.call('fileManager', 'getFile', "browser/scripts/config.json"));
        const wallet = myconf.wallet.address;
        const privateKey = myconf.wallet.privateKey;
        
        if (privateKey === "")
        {
            throw "private key is empty";
        }
        
        NONCE = await web3.eth.getTransactionCount(wallet);
        
        const artifactsPath = `browser/contracts/artifacts/AuthContract.json`;
        const authContract = await deployContract(wallet, privateKey, libraries, artifactsPath);
        NONCE += 1;
        
        const contracts = {
            "RandomContract": null,
            "CharacterContract": null,
            "FightContract": null,
            "FightManagerContract": null,
            "EquipmentContract": null,
            "EquipmentManagerContract": null,
            "Act1Milestones": null,
            "Act1Sidequests": null
        };
					
        for (let contractName in contracts)
        {
            console.log(`Deploying ${contractName}`);
            const artifactsPath = `browser/contracts/artifacts/${contractName}.json`;
            contracts[contractName] = await deployContract(
                wallet, privateKey, libraries, artifactsPath, [authContract.options.address]);
            NONCE += 1;
        }
        
        contracts["AuthContract"] = authContract;
        
        console.log("Contracts:");
        
        const contractsJson = {};

        for (let contractName in contracts)
        {
            contractsJson[contractName] = contracts[contractName].options.address;
            console.log(`${contractName}: "${contracts[contractName].options.address}"`);
        }

        await remix.call("fileManager", "setFile", `browser/deployed/contracts.json`, JSON.stringify(contractsJson));
        console.log("Done");
    }
    catch(e)
    {
        console.log(e);
        throw e;
    }
})();
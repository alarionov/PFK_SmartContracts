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

async function deployContract(wallet, privateKey, artifactsPath, args) 
{
    const metadataJson = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const metadata = linkLibraries(metadataJson, LIBRARIES);
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

const LIBRARIES = {
    "ComputedStats": "0x76CD5A45757131A9447963bFCE02bB38Fe2821fc",
    "Experience": "0xB180140C1f38172F652cF7998e83053e47BF1B0d",
    "GameMath": "0x667591B9deBC4Fc57eb01992bc48e6E7E743c101",
    "SeedReader": "0xBA2090f24133B154c32B49D887A32D501BbF2fBC",
    "Utils": "0x3f21Ad62f76d2aDC3B2A6F3670C318f84a3FDE1A"
};

let NONCE = 0;
(async () => {
    try {
        console.log("....................................");
        
        const wallet = "0x8229d792c1BCCdb9Cc336821502aC906005317a6";
        const privateKey = "93fc8fe13e93f6fde887374afee9a5ee456b963d90278d1d88f3a2592586984c";
        
        if (privateKey === "")
        {
            throw "private key is empty";
        }
        
        NONCE = await web3.eth.getTransactionCount(wallet);
        
        const artifactsPath = `browser/contracts/artifacts/AuthContract.json`;
        const authContract = await deployContract(wallet, privateKey, artifactsPath);
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
            contracts[contractName] = await deployContract(wallet, privateKey, artifactsPath, [authContract.options.address]);
            NONCE += 1;
        }
        
        contracts["AuthContract"] = authContract;
        
        console.log("Contracts:");
        
        for (let contractName in contracts)
        {
            console.log(`${contractName} ${contracts[contractName].options.address}`);
        }
    }
    catch(e)
    {
        console.log(e);
    }
})()

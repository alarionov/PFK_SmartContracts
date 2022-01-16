async function getRawTx(wallet, data, to, value) 
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

async function loadContract(contractName, contractAddress) 
{
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json`;
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const contract = new web3.eth.Contract(metadata.abi, contractAddress);
    
    return contract;
}

async function deployContract(wallet, privateKey, artifactsPath, args) 
{
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    //const metadata = linkLibraries(metadataJson, LIBRARIES);
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

async function callsToContract(wallet, privateKey, contract, calls)
{
    for (const call of calls)
    {
        const method = call.method;
        const args = call.args;
        
        console.log(`Calling ${method} with ${args.join(" ")}`);
        
        const data = contract.methods[call.method](...args).encodeABI();
        const rawTx = await getRawTx(wallet, data, contract.options.address);
        const response = await sendTransaction(rawTx, privateKey);

        NONCE += 1;
    }
}

let NONCE = 0;
(async () => {
    console.log("....................................");

    const CONTRACT_ADDRESSES = JSON.parse(await remix.call('fileManager', 'getFile', "browser/deployed/contracts.json"));
    const myconf = JSON.parse(await remix.call('fileManager', 'getFile', "browser/scripts/config.json"));
    const wallet = myconf.wallet.address;
    const privateKey = myconf.wallet.privateKey;
    
    if (wallet == "" || privateKey == "")
    {
        throw "invalid config";
    }
    
    let contracts = {
        "AuthContract": null,
        "RandomContract": null,
        "CharacterContract": null,
        "ExperienceContract": null,
        "UpgradeContract": null,
        "FightContract": null,
        "FightManagerContract": null,
        "EquipmentContract": null,
        "EquipmentManagerContract": null,
        "Act1Milestones": null,
        "Act1Sidequests": null
    };
				
    for (let contractName in CONTRACT_ADDRESSES)
    {
        const contractAddress = CONTRACT_ADDRESSES[contractName];
        contracts[contractName] = await loadContract(contractName, contractAddress);
    }

    NONCE = await web3.eth.getTransactionCount(wallet);
    
    console.log("Deploy PurrOwnership contract");
    const artifactsPath = `browser/contracts/artifacts/PurrOwnership.json`;
    const purrOwnershipContract = await deployContract(wallet, privateKey, artifactsPath);
    NONCE += 1;

    await callsToContract(wallet, privateKey, contracts["AuthContract"], [
        { method: "setRole", args: [purrOwnershipContract.options.address, /* Character Contract role */ 1] },
    ]);

    await callsToContract(wallet, privateKey, purrOwnershipContract, [
        { method: "setOwner", args: ["0x367043feEDd3C23920157B95f3553f5Edab0ea8F", 3029] },
        { method: "setOwner", args: ["0x367043feEDd3C23920157B95f3553f5Edab0ea8F", 3031] },
        { method: "setAuthority", args: ["0x367043feEDd3C23920157B95f3553f5Edab0ea8F"]},
    ]);

    console.log(`PurrOwnership: ${purrOwnershipContract.options.address}`);
    CONTRACT_ADDRESSES["PurrOwnership"] = purrOwnershipContract.options.address;
    await remix.call("fileManager", "setFile", `browser/deployed/contracts.json`, JSON.stringify(CONTRACT_ADDRESSES));
})();
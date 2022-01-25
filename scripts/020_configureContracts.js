async function getRawTx(wallet, data, to, value) 
{
    const gasPrice = web3.utils.toWei('2', 'gwei');
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
    
    if (privateKey === "")
    {
        throw "private key is empty";
    }
    
    NONCE = await web3.eth.getTransactionCount(wallet);
    
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
    
    //*
    for (let contractName in contracts)
    {
        console.log(`Loaded ${contractName} at ${contracts[contractName].options.address}`);
    }
    /**/
    
    await callsToContract(wallet, privateKey, contracts["AuthContract"], [
        { method: "setRole", args: [contracts["CharacterContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["ExperienceContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["UpgradeContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["FightContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["FightManagerContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["EquipmentContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["EquipmentManagerContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["Act1Milestones"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["Act1Sidequests"].options.address, /* Game Contract role */ 2] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["UpgradeContract"], [
        { method: "setCharacterContractAddress", args: [contracts["CharacterContract"].options.address] },
    ]);

    await callsToContract(wallet, privateKey, contracts["FightContract"], [
        { method: "setRandomContractAddress", args: [contracts["RandomContract"].options.address] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["FightManagerContract"], [
        { method: "setRandomContractAddress", args: [contracts["RandomContract"].options.address] },
        { method: "setCharacterContractAddress", args: [contracts["CharacterContract"].options.address] },
        { method: "setExperienceContractAddress", args: [contracts["ExperienceContract"].options.address] },
        { method: "setFightContractAddress", args: [contracts["FightContract"].options.address] },
        { method: "setEquipmentContractAddress", args: [contracts["EquipmentContract"].options.address] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["EquipmentContract"], [
        { method: "setItemParameters", args: [/* type id */ 1, "Wooden Shield", /* slot shield*/ 3, 0,0,0,0, /* armor */ 1] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["EquipmentManagerContract"], [
        { method: "setCharacterContractAddress", args: [contracts["CharacterContract"].options.address] },
        { method: "setEquipmentContractAddress", args: [contracts["EquipmentContract"].options.address] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["Act1Sidequests"], [
        { method: "setMainMapContractAddress", args: [contracts["Act1Milestones"].options.address] },
        { method: "setEquipmentContractAddress", args: [contracts["EquipmentContract"].options.address] },
        { method: "setWoodenShieldId", args: [/* wooden shield type id */ 1] },
    ]);
    
    console.log("Done");
})();
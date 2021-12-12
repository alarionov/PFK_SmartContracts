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

const CONTRACT_ADDRESSES = {
    RandomContract: "0xBE4Ae8549376Da17f279e1fEE15E3Bff10351530",
    CharacterContract: "0xFAA7E295919ca7B198F962dd77F67DDf7A6A1840",
    FightContract: "0xa16C473DF6873f8AEB562DE52Aa15451F9186fF2",
    FightManagerContract: "0x6256f79a9d115165713244c59be412C61149A9f5",
    EquipmentContract: "0x50C4b0C28B5bc768414e75EC7FDCa6Ab02C4396A",
    EquipmentManagerContract: "0xa96B98DfAAe337923c89F16824049bc75080d999",
    Act1Milestones: "0x24d1407f640f94d29BD985c567920a8581A526Fe",
    Act1Sidequests: "0x32A6adac9baB58a759AD563664Fd3770d6AF59Ee",
    AuthContract: "0x138753D3127C3c0d83a200DE732a753885cca4E2",
};

let NONCE = 0;
(async () => {
    console.log("....................................");
    
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
        { method: "setRole", args: [contracts["FightContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["FightManagerContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["EquipmentContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["EquipmentManagerContract"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["Act1Milestones"].options.address, /* Game Contract role */ 2] },
        { method: "setRole", args: [contracts["Act1Sidequests"].options.address, /* Game Contract role */ 2] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["FightContract"], [
        { method: "setRandomContractAddress", args: [contracts["RandomContract"].options.address] },
    ]);
    
    await callsToContract(wallet, privateKey, contracts["FightManagerContract"], [
        { method: "setRandomContractAddress", args: [contracts["RandomContract"].options.address] },
        { method: "setCharacterContractAddress", args: [contracts["CharacterContract"].options.address] },
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
})()
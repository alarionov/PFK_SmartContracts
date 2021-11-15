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
    "AuthContract": "0xef2371968287B8Cc8f063Af8B497498BdD6FfF03",
    "RandomContract": "0xE3659A17D1eeec8E9f24BcBC76d3C1fd48Ab4880",
    "CharacterContract": "0xB152dD6fa4D2e4a86C385a3217Afb866B691374C",
    "FightContract": "0x3AF816A2cE5aCc8Fa1A918381B8375B372f3e783",
    "FightManagerContract": "0xaEB6F6bC492025B4A0597E5a1a05c5094ce35ddc",
    "EquipmentContract": "0x507eDC3528a83701F43C69c4F097EcfB394f8f4c",
    "EquipmentManagerContract": "0x2bCF7c3EC331d8234D0a7C5E4D27A9f64b609a3a",
    "Act1Milestones": "0x6b6992dD2C14FDb0b77A31641f4710c603B30022",
    "Act1Sidequests": "0x2499aaa7DE00ca0Fb0Ea745aedD745Bec4e51b55"
};

let NONCE = 0;
(async () => {
    console.log("....................................");
    
    const wallet = "0x8229d792c1BCCdb9Cc336821502aC906005317a6";
    const privateKey = "93fc8fe13e93f6fde887374afee9a5ee456b963d90278d1d88f3a2592586984c";
    
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
        { method: "setRole", args: [contracts["CharacterContract"].options.address, /* Character Contract role */ 2] },
        { method: "setRole", args: [contracts["FightContract"].options.address, /* Game Contract role */ 1] },
        { method: "setRole", args: [contracts["FightManagerContract"].options.address, /* Game Contract role */ 1] },
        { method: "setRole", args: [contracts["EquipmentContract"].options.address, /* Game Contract role */ 1] },
        { method: "setRole", args: [contracts["EquipmentManagerContract"].options.address, /* Game Contract role */ 1] },
        { method: "setRole", args: [contracts["Act1Milestones"].options.address, /* Game Contract role */ 1] },
        { method: "setRole", args: [contracts["Act1Sidequests"].options.address, /* Game Contract role */ 1] },
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
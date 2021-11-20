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
    AuthContract: "0xC306eE22592f8c6f0AA9b2a0797596f63be56bA1",
    RandomContract: "0x835Fa2A577e5dCB39FFe2911D6eA6795737E4906",
    CharacterContract: "0x8D2F530793D3F05D24aa86dE1464880C72A53d30",
    FightContract: "0x1BE71728fdc44B3482d06f5eC3afc8Ccd1b977bb",
    FightManagerContract: "0xAD04F3Dd0216956FFeB67B70167947674e9A1862",
    EquipmentContract: "0x70C6E0a66B5c489Ab065029abb4c39Cf996Fb38F",
    EquipmentManagerContract: "0x441e45f30E7215875ba98793390f0aEa8C794389",
    Act1Milestones: "0x24b2a0eD0315191fB764fC1ad6443368B4Eb4c55",
    Act1Sidequests: "0xFd927588A534906b3d3DC71D12eb34011B0a1a76"
};

// Purr Ownership 0x83D1EE256345B48327dcAc1D93B65bC179d456Ad

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
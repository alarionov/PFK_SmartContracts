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

const CONTRACT_ADDRESSES = {
    RandomContract: "0xcb9E02B3a5E65f8E26fD99F4c941f147B7562EcD",
    CharacterContract: "0x4D43fd57Be372979B78Ac546a8f1ce0E24234427",
    FightContract: "0x60DCBBA0592a9E4E272dB2C12F6c689A51a2844f",
    FightManagerContract: "0xfB0DDA770D1026Fde58B582dEE8EA3C6fC5daC8B",
    EquipmentContract: "0xD30930E0e39CdBCD2eC18A0E720c023B88055bF7",
    EquipmentManagerContract: "0x0dB31e7b58BbE84a69826491c1Aa3dC4d17c5c0E",
    Act1Milestones: "0xEd62739aCaAB6b21E9D3335Eb256f7Df6f0BBF36",
    Act1Sidequests: "0x57F4F49780c4613995F7872e457157FA0bCdD609",
    AuthContract: "0x1aF5F8DEA3FC1CcBDE371B2989C84B4DAc1C90D3"
};

let NONCE = 0;
(async () => {
    console.log("....................................");
    
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
    ]);

    console.log(`PurrOwnership: ${purrOwnershipContract.options.address}`);
    // 0x0f0f9537ab6f1a230854e5CB654736C4DC979bE6 
})();
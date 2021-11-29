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
    AuthContract: "0xCc372fD17eFCd99C85bBf26969F774bB6b27dfeC",
    RandomContract: "0xBeB8d5b198c6FFbd3027dd126883db390c9d226B",
    CharacterContract: "0x86c82ad509236b39651d229D306951E97733F5F3",
    FightContract: "0x541468E2Bcfb987E5F2b09e1503f4365a360790a",
    FightManagerContract: "0x301fb5F54f9b508e6E5609eF1dDAD7D2C774bc8b",
    EquipmentContract: "0x2FD1EA8099573DDb6cB331f789EE39062e431f21",
    EquipmentManagerContract: "0x151a64275c8910F7FC6855d86C16c17943E1811F",
    Act1Milestones: "0xf7509aF5A7cCEbA910E45e911b7c508af1fbDbEC",
    Act1Sidequests: "0xb02A4F1d6128cB80a80681D05dddCFa475A770eF"    
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
    // 0x531cF4ff21a8d0C3baD6Cb8Ec30061b2269D04fA
})();
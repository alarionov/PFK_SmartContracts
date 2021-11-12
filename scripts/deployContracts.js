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
    ComputedStats: "0xb01668351168342173927799a19c524588Eb5D09",
    Experience: "0xE59d43B028541054570BFCDAbDF6609Be993A769",
    GameMath: "0x42eBad262F9fd1f4D55B510C44164B9cdB61fc22",
    SeedReader: "0x8c4D25f1359E064E039E6Ec04A133b1140dc2Ccb",
    Utils: "0x836e7eba35F8441d7eD63cc8c81C0F37B1c16017"
};

/*
RandomContract 0xe460a7Fc82bCfF0D663EA5F1552a0FEe0BCA53b6
GameManager 0x9135D512E685b5Fb3c08dee49300F136AE4374c8
CharacterContract 0x4F179eB786540014435783607edbFC70299DfD16
FightContract 0x95e21E0D2118184fc7ebb0cCd42d4AeC8c0a3EE6
Act1Milestones 0xE226bebE0413B0330AB023A0Ebd9414605257912
Act1Sidequests 0xC6bD0a7a420303D5D495c1A4D7B7AF4969619D9e
*/

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
        
        return;
        
        /*
        const settings = [
            { method: "setCoreContractAddress", value: contracts["GameManager"].options.address },
            { method: "setCharacterContractAddress", value: contracts["WordBearer"].options.address },
            { method: "setFightContractAddress", value: contracts["FightLogic"].options.address },
        ];
        
        for (const params of settings)
        {
            for (const contractName of ["Random", "GameManager", "WordBearer", "FightLogic", "FightToken"])
            {
                console.log(`Calling ${params.method} on ${contractName}`);
                
                const contract = contracts[contractName];
                
                if (contract.options.address === params.value) continue;
                
                const data = contract.methods[params.method](params.value).encodeABI();
                const rawTx = await getRawTx(wallet, data, contract.options.address);
                const response = await sendTransaction(rawTx, privateKey);

                NONCE += 1;
            }
        }
        
        for (const contractName of ["GameManager", "WordBearer", "FightLogic"])
        {
            console.log(`Setting Random contract on ${contractName}`);
            
            const contract = contracts[contractName];
            
            const data = contract.methods.setRandomContractAddress(contracts["Random"].options.address).encodeABI();
            const rawTx = await getRawTx(wallet, data, contract.options.address);
            const response = await sendTransaction(rawTx, privateKey);
            
            NONCE += 1;
        }
        
        const additionFLSettings = [
            { method: "setMapContractAddress", value: contracts["Map"].options.address },
        ];
        
        for (const params of additionFLSettings)
        {
            console.log(`Calling ${params.method} on FightLogic`);
            
            const contract = contracts["FightLogic"];
            const data = contract.methods[params.method](params.value).encodeABI();
            const rawTx = await getRawTx(wallet, data, contract.options.address);
            const response = await sendTransaction(rawTx, privateKey);

            NONCE += 1;
        }
        
        const additionCoreSettings = [
            { method: "setWordContractAddress", value: contracts["WordMock"].options.address },
            { method: "setFightTokenContractAddress", value: contracts["FightToken"].options.address }
        ];
        
        for (const params of additionCoreSettings)
        {
            console.log(`Calling ${params.method} on GameManager`);
            const contract = contracts["GameManager"];
            const data = contract.methods[params.method](params.value).encodeABI();
            const rawTx = await getRawTx(wallet, data, contract.options.address);
            const response = await sendTransaction(rawTx, privateKey);

            NONCE += 1;
        }
        
        for (let i = 0; i <= 2; ++i)
        {
            console.log(`Registering words`);
            
            const contract = contracts["GameManager"];
            const data = contract.methods.registerWord(i).encodeABI();
            const rawTx = await getRawTx(wallet, data, contract.options.address, web3.utils.toWei('0.1', 'ether'));
            const response = await sendTransaction(rawTx, privateKey);

            NONCE += 1;
        }
        
        await (async () => {
            console.log("Starting the season");
            
            const contract = contracts["GameManager"];
            const data = contract.methods.startSeason().encodeABI();
            const rawTx = await getRawTx(wallet, data, contract.options.address);
            const response = await sendTransaction(rawTx, privateKey);

            NONCE += 1;
        })();
        */
    }
    catch(e)
    {
        console.log(e);
    }
})()

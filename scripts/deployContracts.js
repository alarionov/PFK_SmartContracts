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

async function deployContract(wallet, privateKey, artifactsPath) 
{
    const metadataJson = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const metadata = linkLibraries(metadataJson, LIBRARIES);
    const contract = new web3.eth.Contract(metadata.abi);
    const data = contract.deploy({data: "0x" + metadata.data.bytecode.object}).encodeABI();
    const rawTx = await getRawTx(wallet, data);
    const response = await sendTransaction(rawTx, privateKey);
    return response.contractAddress;
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
    "ComputedStats": "0xB06374F9De9e8F98341c4c3349a25dA229e20919",
    "GameMath": "0xcc1e70c46E0F9A71f522862Da52765ca573FAD14",
    "SeedReader": "0xbCfF6019C9B75748b85d58867306A9d7DA571c91",
    "Utils": "0xB092Ba8eAF2B58617e1A6B227617162aa3804AF1"
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
        const privateKey = "";
        
        if (privateKey === "")
        {
            throw "private key is empty";
        }
        
        NONCE = await web3.eth.getTransactionCount(wallet);
        
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
            contracts[contractName] = await deployContract(wallet, privateKey, artifactsPath);
            NONCE += 1;
        }
        
        console.log("Contracts:");
        
        for (let contractName in contracts)
        {
            console.log(`${contractName} ${contracts[contractName]}`);
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

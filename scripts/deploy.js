const getRawTx = async (wallet, data, to, value) => {
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
};

const sendTransaction = async (rawTx, privateKey) => 
{
    const signedTx = await web3.eth.accounts.signTransaction(rawTx, privateKey);
    const response = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    return response;
};

const deployContract = async (wallet, privateKey, contractName) => {
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json`;
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const contract = new web3.eth.Contract(metadata.abi);
    const data = contract.deploy({data: "0x" + metadata.data.bytecode.object}).encodeABI();
    const rawTx = await getRawTx(wallet, data);
    const response = await sendTransaction(rawTx, privateKey);
    return new web3.eth.Contract(metadata.abi, response.contractAddress);
};

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
            "WordMock": null,
            "Random": null,
            "GameManager": null,
            "WordBearer": null,
            "FightLogic": null,
            "FightToken": null,
            "Map": null
        };
        
        for (let contractName in contracts)
        {
            console.log(`Deploying ${contractName}`);
            contracts[contractName] = await deployContract(wallet, privateKey, contractName);
            NONCE += 1;
        }
        
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
        
        console.log("Contracts:");
        
        for (let contractName in contracts)
        {
            console.log(`${contractName + " ".repeat(12 - contractName.length)} ${contracts[contractName].options.address}`);
        }
    }
    catch(e)
    {
        console.log(e);
    }
})()

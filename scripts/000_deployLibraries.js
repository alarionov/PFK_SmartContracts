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

async function deployLibrary(wallet, privateKey, artifactsPath) 
{
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    const contract = new web3.eth.Contract(metadata.abi);
    const data = contract.deploy({data: "0x" + metadata.data.bytecode.object}).encodeABI();
    const rawTx = await getRawTx(wallet, data);
    const response = await sendTransaction(rawTx, privateKey);
    return response.contractAddress;
}

let NONCE = 0;
(async () => {
    try {
        console.log("....................................");
        
        const myconf = JSON.parse(await remix.call('fileManager', 'getFile', "browser/scripts/config.json"));
        const wallet = myconf.wallet.address;
        const privateKey = myconf.wallet.privateKey;
        
        if (privateKey === "")
        {
            throw "private key is empty";
        }
        
        NONCE = await web3.eth.getTransactionCount(wallet);
        
        const libraries = {
            ComputedStats: null,
            Experience: null,
            GameMath: null,
            SeedReader: null,
            Utils: null
        };
        
        for (let libraryName in libraries)
        {
            console.log(`Deploying ${libraryName}`);
            const artifactsPath = `browser/contracts/libraries/artifacts/${libraryName}.json`;
            libraries[libraryName] = await deployLibrary(wallet, privateKey, artifactsPath);
            NONCE += 1;
        }
        
        console.log("Libraries:");
        
        await remix.call("fileManager", "setFile", `browser/deployed/libraries.json`, JSON.stringify(libraries));

        for (let libraryName in libraries)
        {
            console.log(`${libraryName} ${libraries[libraryName]}`);
        }
    }
    catch(e)
    {
        console.log(e);
        throw e;
    }
})()

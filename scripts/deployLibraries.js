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
        
        const wallet = "0x8229d792c1BCCdb9Cc336821502aC906005317a6";
        const privateKey = "93fc8fe13e93f6fde887374afee9a5ee456b963d90278d1d88f3a2592586984c";
        
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
        
        for (let libraryName in libraries)
        {
            console.log(`${libraryName} ${libraries[libraryName]}`);
        }
    }
    catch(e)
    {
        console.log(e);
    }
})()

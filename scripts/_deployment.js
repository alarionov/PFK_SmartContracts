(async () => {
    console.log("START DEPLOYMENT");
    
    const scripts = [
        "000_deployLibraries.js",
        "010_deployContracts.js",
        "020_configureContracts.js",
        
        "100_purrOwnership.js",
        "200_extractAbi.js",
    ];

    try
    {
        for (const script of scripts)
        {
            console.log(`=== START ${script} ===`);
            await eval(
                await remix.call(
                    'fileManager', 'getFile', `browser/scripts/${script}`));
            console.log(`=== FINISH ${script} ===`);
        }
        console.log("FINISH DEPLOYMENT");
    }
    catch(e)
    {
        console.log(e);
        throw e;
    }
})();
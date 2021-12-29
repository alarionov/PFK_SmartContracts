(async () => {
    console.log("Start Deployment");
    
    const scripts = [
        "000_deployLibraries.js",
        "010_deployContracts.js",
        "020_configureContracts.js",
        "030_extractAbi.js",
        "100_purrOwnership.js"
    ];

    for (const script of scripts)
    {
        console.log(`=== EXECUTING ${script} ===`);
        await eval(
            await remix.call(
                'fileManager', 'getFile', `browser/scripts/${script}`));
    }
    console.log("done");
})();
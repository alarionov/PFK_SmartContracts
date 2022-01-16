async function extractABI(contractName) 
{
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json`;
    const abiPath = `browser/contracts/ABI/${contractName}.json`;
    
    console.log(`Extracting Abi from ${artifactsPath} to ${abiPath}`);
    
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));
    await remix.call("fileManager", "setFile", abiPath, JSON.stringify(metadata.abi));
}

(async () => {
    const contracts = [
        "AuthContract",
        "RandomContract",
        "CharacterContract",
        "ExperienceContract",
        "UpgradeContract",
        "FightContract",
        "FightManagerContract",
        "EquipmentContract",
        "EquipmentManagerContract",
        "Act1Milestones",
        "Act1Sidequests",
        "PurrOwnership",
    ];
    
    for (let i = 0; i < contracts.length; ++i)
    {
        const contractName = contracts[i];
        await extractABI(contractName);
    }
})();
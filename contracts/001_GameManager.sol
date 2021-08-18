// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

contract GameManager is BaseContract, CoreContract
{
    using EnumerableSet for EnumerableSet.UintSet;
    
    /* events */
    event Buffs(bool[]);
    event StateChange(PlayerState);
    
    enum SeasonStage
    {
        PRESEASON,
        SEASON,
        POSTSEASON
    }
    
    mapping(uint => EnumerableSet.UintSet) private _registered_word_ids;
    mapping(uint => uint) private _season_prize_pool;
    
    address public WORD_CONTRACT_ADDRESS = address(0x0);
    
    uint private WORD_MIN_LENGTH = 3;
    uint private WORD_MAX_LENGTH = 5;
    
    uint private MIN_REWARD = 0.001 ether;
    
    mapping(address => uint) private _balances;
    
    address public FIGHT_TOKEN_CONTRACT_ADDRESS;
    
    uint private SPELL_CAST_FEE = 0.001 ether;
    
    uint private SEASON = 0;
    
    SeasonStage public SEASON_STAGE = SeasonStage.PRESEASON;
    
    mapping(uint => mapping(address => PlayerState)) private _player_states;
    mapping(uint => mapping(address => uint)) private scores;
    mapping(address => bool[]) private _buffs;
    
    Spell[] private _spells;
    
    mapping(uint => LeaderboardRecord[]) private _leaderboards;
    
    modifier duringPreSeason()
    {
        require(SEASON_STAGE == SeasonStage.PRESEASON, "Can be called only during a pre-season stage");
        _;
    }
    
    modifier duringSeason()
    {
        require(SEASON_STAGE == SeasonStage.SEASON, "Can be called only during a season stage");
        _;
    }
    
    modifier duringPostSeason()
    {
        require(SEASON_STAGE == SeasonStage.POSTSEASON, "Can be called only during a post-season stage");
        _;
    }
    
    constructor() BaseContract()
    {
        CORE_CONTRACT_ADDRESS = address(this);
        
        // COMMON (1 word)
        _spells.push(Spell({name: "ENCHANT", words: new uint[](1)}));
        _spells.push(Spell({name: "FALSELIFE", words: new uint[](1)}));
        _spells.push(Spell({name: "SHIELD", words: new uint[](1)}));
    
        // UNCOMMON (2 words)
    
        // RARE (3 words)
        _spells.push(Spell({name: "CRIT", words: new uint[](3)}));
        _spells.push(Spell({name: "BLESS", words: new uint[](3)}));
    
        // EPIC (4 words)
        _spells.push(Spell({name: "REFLECT", words: new uint[](4)}));
        _spells.push(Spell({name: "LIFEDRAIN", words: new uint[](4)}));
    
        // LEGENDARY (5words), depletable, 1 charge
        _spells.push(Spell({name: "SALVATION", words: new uint[](5)}));
        
        SEASON_STAGE = SeasonStage.PRESEASON;
    }
    
    function showRewards(address player) public view returns (uint amount)
    {
        amount = _balances[player];
    }
    
    function withdrawRewards() public 
    {
        address player = msg.sender;
        
        require(_balances[player] > 0, "Nothing to withdraw");
        
        uint amount = _balances[player];
        _balances[player] = 0;
        
        (bool sent, bytes memory data) = payable(player).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    
    /* WORDS */
    function setWordContractAddress(address newContractAddress) public onlyGM
    {
        WORD_CONTRACT_ADDRESS = newContractAddress;
    }
    
    function setFightTokenContractAddress(address newAddress) public onlyGM
    {
        FIGHT_TOKEN_CONTRACT_ADDRESS = newAddress;        
    }
    
    function getPartialReward(uint placement) public view returns (uint reward)
    {
        if (placement > 5 || placement == 0) return 0;
        
        return (6 - placement) * MIN_REWARD;
    }
    
    function getWordRegistrationFee() public view returns (uint total)
    {
        total = 0;
        
        for (uint i = 1; i < 6; ++i)
        {
            total += getPartialReward(i);
        }
    }
    
    function registerWord(uint token_id) payable external duringPreSeason
    {
        require(msg.value == getWordRegistrationFee(), "Fee does not match");
        
        Word wordContract = Word(WORD_CONTRACT_ADDRESS);
        address word_owner = wordContract.ownerOf(token_id);
        
        require(msg.sender == word_owner, "Should be an owner to register a word");
        
        string memory word = wordContract.getWord(token_id);
        
        require(_validateWord(word), "Word should be valid to be registered");
        
        if (EnumerableSet.add(_registered_word_ids[SEASON], token_id))
        {
            // emit event
        }
    }
    
    function validateWord(uint token_id) view external returns (bool)
    {
        Word wordContract = Word(WORD_CONTRACT_ADDRESS);
        
        string memory word = wordContract.getWord(token_id);
        
        return _validateWord(word);
    }
    
    function _validateWord(string memory word) view private returns (bool)
    {
        bytes memory bStr = bytes(word);
        bytes memory hyphen = bytes("-");
        
        if (bStr.length < WORD_MIN_LENGTH)
            return false;
        if (bStr.length > WORD_MAX_LENGTH)
            return false;
        
        for (uint i = 0; i < bStr.length; ++i)
        {
            if (bStr[i] == hyphen[0])
                return false;
        }
        
        return true;
    }
    
    function _awardWordOwners(uint[] memory _ids) private
    {
        Word wordContract = Word(WORD_CONTRACT_ADDRESS);
         
        for (uint i; i < _ids.length; ++i)
        {
            address wordOwner = wordContract.ownerOf(_ids[i]);
            _balances[wordOwner] += SPELL_CAST_FEE;
        }
    }
    
    /* SEASON */
    function getCurrentSeason() public view override(CoreContract) returns (uint season)
    {
        season = SEASON;
    }
    
    /* PreSeason To Season */
    function startSeason() public onlyGM duringPreSeason
    {
        SEASON_STAGE = SeasonStage.SEASON;
        
        for (uint i = 0; i < 5; ++i)
        {
            _leaderboards[SEASON].push(
                LeaderboardRecord({
                    player: address(0x0),
                    score: 0
                }));
        }
        
        _initSpells();
    }
    
    /* Season to PostSeason */
    function finishSeason() public onlyGM duringSeason
    {
        SEASON_STAGE = SeasonStage.POSTSEASON;
    }
    
    /* Post Season to Pre Season */
    function startNewSeason() public onlyGM duringPostSeason
    {
        SEASON += 1;
    }
    
    function awardLeaderboard() public onlyGM duringPostSeason
    {
        uint totalWords = EnumerableSet.length(_registered_word_ids[SEASON]);
        
        for (uint i = 0; i < 5; ++i)
        {        
            address player = _leaderboards[SEASON][i].player;
            
            if (player == address(0x0))
                continue;
                
            _balances[player] += getPartialReward(i+1) * totalWords;
        }
    }
    
    /* VIEW FUNCTIONS */
    
    function getState(address player) public view returns (PlayerState memory)
    {
        return _player_states[SEASON][player];
    }
    
    function resetState(address player) public onlyGM
    {
        _player_states[SEASON][player] = PlayerState(0,0,0);
    }
    
    function getScore(address player) public view returns (uint score)
    {
        score = scores[SEASON][player];
    }
    
    function conductFight() external duringSeason
    {
        address player = msg.sender;
        PlayerState storage state = _player_states[SEASON][player];
        
        require(state.tokenId != 0, "The address doesn't have any character assigned");
        
        FightContract fightContract = FightContract(FIGHT_CONTRACT_ADDRESS);
        
        Fight memory fight = fightContract.conductFight(state, _buffs[player]);
        
        FightTokenContract fightTokenContract = FightTokenContract(FIGHT_TOKEN_CONTRACT_ADDRESS);
        fightTokenContract.mint(player, fight);
        
        if (fight.score > 0)
        {
            scores[SEASON][player] += fight.score;
            
            _adjustLeaderboard(player, scores[SEASON][player]);
        }   
        
        _player_states[SEASON][player] = fight.newState;
        
        _resetBuffs(player);
        
        CharacterContract characterContract = CharacterContract(CHARACTER_CONTRACT_ADDRESS);
        
        if (fight.died)
            characterContract.killCharacter(player, fight.oldState.tokenId);   
        else if (fight.score > 0)
            characterContract.addExp(player, fight.oldState.tokenId, fight.score);
    }
    
    function _adjustLeaderboard(address player, uint score) private
    {
        LeaderboardRecord[] storage records = _leaderboards[SEASON];
        
        address newEntry = player;
        
        for (uint i = 0; i < records.length; ++i)
        {
            if (records[i].score >= score)
            {
                continue;
            }
            
            (player, score) = _swapLeaderboardRecords(records[i], player, score);
            
            if (player == newEntry || player == address(0x0)) return;
        }
    }
    
    function getLeaderboard() public view returns (LeaderboardRecord[] memory records)
    {
        records = _leaderboards[SEASON];
    }
    
    
    function _swapLeaderboardRecords(LeaderboardRecord storage record, address player, uint score) private returns (address replacedPlayer, uint replacedScore)
    {
        replacedPlayer = record.player;
        replacedScore = record.score;
            
        record.player = player;
        record.score = score;
    }
    
    /* CHARACTER */
    function getCharacterIdByAddress(address player) external view returns (uint tokenId)
    {
        return _player_states[SEASON][player].tokenId;
    }
    
    function registerCharacter(uint character) external duringSeason
    {
        address player = msg.sender;
        PlayerState storage state = _player_states[SEASON][player];
        
        require(state.tokenId == 0, "Player can have only one character alive");
        
        CharacterContract  characterContract = CharacterContract(CHARACTER_CONTRACT_ADDRESS);
        
        state.tokenId = characterContract.createCharacter(player, character);
        
        emit StateChange(state);
        
        _resetBuffs(player);
    }
    
    /* SPELLS */
    function _resetBuffs(address player) private
    {
        _buffs[player] = new bool[](_spells.length);
        
        emit Buffs(_buffs[player]);
    }
    
    function getBuffs(address player) external view returns (bool[] memory buffs)
    {
        buffs = _buffs[player];
    }
    
    function castSpell(uint index) public payable duringSeason
    {
        address player = msg.sender;
        PlayerState storage state = _player_states[SEASON][player];
        
        require(state.tokenId != 0, "The address doesn't have any character assigned");
        
        require(index < _spells.length, "Invalid spell index");
        
        Spell storage spell = _spells[index];
        
        require(msg.value == spell.words.length * SPELL_CAST_FEE, "Spell cast fee doesn't match");
        
        _awardWordOwners(spell.words);
        
        require(!_buffs[player][index], "Cast has been applied already");
        
        _buffs[player][index] = true;
        
        emit Buffs(_buffs[player]);
        
        _initSpell(spell);
    }
    
    function _initSpells() private
    {
        require(_spells.length > 0, "No spells have been registered");
        
        require(
            EnumerableSet.length(_registered_word_ids[SEASON]) > 0,
            "No words have been registered");
        
        for (uint i = 0; i < _spells.length; ++i)
        {
            _initSpell(_spells[i]);
        }
    }
    
    function _initSpell(Spell storage spell) private
    {
        uint totalWords = EnumerableSet.length(_registered_word_ids[SEASON]);
        
        require(totalWords > 0, "No words have been registered");
        
        for (uint i = 0; i < spell.words.length; ++i)
        {
            uint index = random() % totalWords;
            spell.words[i] = EnumerableSet.at(_registered_word_ids[SEASON], index);
        }
    }
}
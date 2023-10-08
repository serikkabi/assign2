contract RockPaperScissors {
    address public player1;
    address public player2;
    bytes32 public encryptedMove1;
    bytes32 public encryptedMove2;
    string public clearMove1;
    string public clearMove2;
    uint256 public constant MIN_BET = 0.0001 ether;
    uint256 public constant REVEAL_TIMEOUT = 86400; // 24 hours in seconds
    uint256 public revealPhaseEndTime;

    enum Moves { None, Rock, Paper, Scissors }
    mapping(bytes32 => Moves) public moveMapping;

    constructor() {
        revealPhaseEndTime = block.timestamp + REVEAL_TIMEOUT;
    }

    function register() external payable {
        require(msg.value >= MIN_BET, "Insufficient funds sent");
        if (player1 == address(0)) {
            player1 = msg.sender;
        } else if (player2 == address(0)) {
            player2 = msg.sender;
        } else {
            revert("Both players are already registered");
        }
    }

    function play(bytes32 encrMove) external {
        require(msg.sender == player1 || msg.sender == player2, "You are not a registered player");
        require(encryptedMove1 == bytes32(0) || encryptedMove2 == bytes32(0), "Moves are already submitted");
        
        if (msg.sender == player1) {
            encryptedMove1 = encrMove;
        } else {
            encryptedMove2 = encrMove;
        }
    }

    function reveal(string memory clearMove) external {
        require(msg.sender == player1 || msg.sender == player2, "You are not a registered player");
        require(keccak256(abi.encodePacked(clearMove)) == encryptedMove1 || keccak256(abi.encodePacked(clearMove)) == encryptedMove2, "Invalid clear move");

        if (msg.sender == player1) {
            clearMove1 = clearMove;
        } else {
            clearMove2 = clearMove;
        }
    }

    function getOutcome() external {
        require(bothRevealed(), "Moves are not revealed yet");
        Moves move1 = moveMapping[encryptedMove1];
        Moves move2 = moveMapping[encryptedMove2];

        // Determine the winner and distribute rewards
        // ... (implement your logic here)

        // Reset game state after the outcome is determined
        resetGame();
    }

    function bothPlayed() public view returns (bool) {
        return encryptedMove1 != bytes32(0) && encryptedMove2 != bytes32(0);
    }

    function bothRevealed() public view returns (bool) {
        return bytes(clearMove1).length > 0 && bytes(clearMove2).length > 0;
    }

    function revealTimeLeft() public view returns (uint256) {
        if (block.timestamp < revealPhaseEndTime) {
            return revealPhaseEndTime - block.timestamp;
        } else {
            return 0;
        }
    }

    function resetGame() internal {
        // Reset game state variables
        player1 = address(0);
        player2 = address(0);
        encryptedMove1 = bytes32(0);
        encryptedMove2 = bytes32(0);
        clearMove1 = "";
        clearMove2 = "";
        revealPhaseEndTime = block.timestamp + REVEAL_TIMEOUT;
    }
}
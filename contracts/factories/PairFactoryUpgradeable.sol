// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import '../interfaces/IPairFactory.sol';
import '../Pair.sol';

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PairFactoryUpgradeable is IPairFactory, OwnableUpgradeable {

    bool public isPaused;

    uint256 public stableFee;
    uint256 public volatileFee;
    uint256 public referralFee;
    uint256 public nftFee;
    uint256 public constant MAX_FEE = 25; // 0.25%

    address public feeManager;
    address public pendingFeeManager;
    address public dibs;                // referral fee handler
    address public nftFeeHandler;       // nft fee handler

    mapping(address => mapping(address => mapping(bool => address))) public getPair;
    address[] public allPairs;
    mapping(address => bool) public isPair; // simplified check if its a pair, given that `stable` flag might not be available in peripherals

    address internal _temp0;
    address internal _temp1;
    bool internal _temp;

    event PairCreated(address indexed token0, address indexed token1, bool stable, address pair, uint);

    modifier onlyManager() {
        require(msg.sender == feeManager);
        _;
    }

    constructor() {}
    function initialize() initializer  public {
        __Ownable_init();
        isPaused = false;
        feeManager = msg.sender;
        stableFee = 2; // 0.02%
        volatileFee = 20; // 0.2%
    }


    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function pairs() external view returns(address[] memory ){
        return allPairs;
    }

    function setPause(bool _state) external {
        require(msg.sender == owner());
        isPaused = _state;
    }

    function setFeeManager(address _feeManager) external onlyManager{
        pendingFeeManager = _feeManager;
    }

    function acceptFeeManager() external {
        require(msg.sender == pendingFeeManager);
        feeManager = pendingFeeManager;
    }

    function setDibs(address _dibs) external onlyManager {
        require(_dibs != address(0));
        dibs = _dibs;
    }

    function setNftFeeHandler(address _handler) external {
        require(msg.sender == feeManager, 'not fee manager');
        require(_handler != address(0), 'address zero');
        nftFeeHandler = _handler;
    }

    function setSecondFee(uint256 _refFee, uint256 _nftFee) external {
        require(msg.sender == feeManager, 'not fee manager');
        require(_refFee + _nftFee <= 10000, 'not fee manager');
        referralFee = _refFee;
        nftFee = _nftFee;
    }

    function setFee(bool _stable, uint256 _fee) external onlyManager {
        require(_fee <= MAX_FEE, 'fee');
        require(_fee != 0);
        if (_stable) {
            stableFee = _fee;
        } else {
            volatileFee = _fee;
        }
    }

    function getFee(bool _stable) public view returns(uint256) {
        return _stable ? stableFee : volatileFee;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(Pair).creationCode);
    }

    function getInitializable() external view returns (address, address, bool) {
        return (_temp0, _temp1, _temp);
    }

    function createPair(address tokenA, address tokenB, bool stable) external returns (address pair) {
        require(tokenA != tokenB, 'IA'); // Pair: IDENTICAL_ADDRESSES
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZA'); // Pair: ZERO_ADDRESS
        require(getPair[token0][token1][stable] == address(0), 'PE'); // Pair: PAIR_EXISTS - single check is sufficient
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, stable)); // notice salt includes stable as well, 3 parameters
        (_temp0, _temp1, _temp) = (token0, token1, stable);
        pair = address(new Pair{salt:salt}());
        getPair[token0][token1][stable] = pair;
        getPair[token1][token0][stable] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        isPair[pair] = true;
        emit PairCreated(token0, token1, stable, pair, allPairs.length);
    }
}

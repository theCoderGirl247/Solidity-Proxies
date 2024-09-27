// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Lottery.sol";

contract Proxy{
    // Mapping to store the implementation addresses
    mapping(bytes4 => address) private implementations;

    // Admin address
    address payable public admin;

    // Lottery contract instance
    Lottery private lottery;
    bool private initialized;

    // Function selectors for the delegated functions
    bytes4 private constant ENTER_LOTTERY_SELECTOR = bytes4(keccak256("enterLottery(uint256)"));
    bytes4 private constant PICK_WINNER_SELECTOR = bytes4(keccak256("pickWinner()"));
    bytes4 private constant GET_PRIZE_SELECTOR = bytes4(keccak256("getPrize()"));

    // Event for when the fallback function is called
    event FallbackCalled(bytes4 sig);

    receive() external payable { }

    // Modifier to restrict access to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    // Constructor to initialize Admin
    constructor() {
        admin = payable(msg.sender);  
    }

    // Set the initial implementation address
    function initialize(address _lotteryAddress) external onlyAdmin {
        require(!initialized, "Proxy already initialized");
        lottery = Lottery(_lotteryAddress);
        implementations[ENTER_LOTTERY_SELECTOR] = _lotteryAddress;
        implementations[PICK_WINNER_SELECTOR] = _lotteryAddress;
        implementations[GET_PRIZE_SELECTOR] = _lotteryAddress;
        initialized = true;
    }

    // Function to update implementation (Admin only)
    function updateImplementation(bytes4 _selector, address _newImplementation) external onlyAdmin {
        implementations[_selector] = _newImplementation;
    }

    // Function to transfer admin ownership (Admin only)
    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address for new admin");
        admin = payable(newAdmin);  
    }

    // Function to enter the lottery
    function enterLottery(uint256 amount) external payable {
        _delegateWithValue(ENTER_LOTTERY_SELECTOR, abi.encode(amount), msg.value);
    }

    // Function to pick the winner
    function pickWinner() external {
        _delegate(PICK_WINNER_SELECTOR, "");
    }

    // Function to get the current prize
    function getPrize() external view returns (uint256) {
        return _delegateView(GET_PRIZE_SELECTOR, "");
    }

    // Internal function to delegate the call to the implementation contract
    function _delegate(bytes4 _selector, bytes memory _params) internal {
        address _impl = implementations[_selector];
        require(_impl != address(0), "Implementation not found");

        (bool success, ) = _impl.call(abi.encodePacked(_selector, _params));
        require(success, "Call failed");
    }

    // Internal function to delegate a call that requires sending value
    function _delegateWithValue(bytes4 _selector, bytes memory _params, uint256 _value) internal {
        address _impl = implementations[_selector];
        require(_impl != address(0), "Implementation not found");

        (bool success, ) = _impl.call{value: _value}(abi.encodePacked(_selector, _params));
        require(success, "Call failed");
    }

    // Internal function to delegate a view function to the implementation contract
    function _delegateView(bytes4 _selector, bytes memory _params) internal view returns (uint256) {
        address _impl = implementations[_selector];
        require(_impl != address(0), "Implementation not found");

        (bool success, bytes memory result) = _impl.staticcall(abi.encodePacked(_selector, _params));
        require(success, "Call failed");
        return abi.decode(result, (uint256));
    }

    // Fallback function to delegate calls
    fallback() external payable {
        bytes4 sig;
        assembly {
            sig := calldataload(0) 
        }
        emit FallbackCalled(sig);
        _delegate(sig, msg.data[4:]);
    }
}

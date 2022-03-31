// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Gold is ERC20, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    mapping(address => bool) private _blacklist;

    event BlacklistAdded(address _account);
    event BlacklistRemoved(address _account);

    constructor() ERC20("GOLD", "GLD") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    function pauseContract() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function resumeContract() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function addToBlacklist(address _account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_account != msg.sender, "Cannot add ADMIN to blacklist");
        require(_blacklist[_account] == false, "Account was on blacklist");
        _blacklist[_account] = true;
        emit BlacklistAdded(_account);
    }

    function removeFromBlacklist(address _account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_blacklist[_account] == true, "Account was not on blacklist");
        _blacklist[_account] = false;
        emit BlacklistRemoved(_account);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(_blacklist[from] == false, "Sender was on blacklist");
        require(_blacklist[to] == false, "Recipient was on blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }
}

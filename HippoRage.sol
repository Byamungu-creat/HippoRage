// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --------------------------------------
// Context.sol (OpenZeppelin)
// --------------------------------------
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// --------------------------------------
// IERC20.sol (OpenZeppelin)
// --------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// --------------------------------------
// ERC20.sol (OpenZeppelin)
// --------------------------------------
contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// --------------------------------------
// Ownable.sol (OpenZeppelin)
// --------------------------------------
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// --------------------------------------
// IAccessControl.sol (OpenZeppelin)
// --------------------------------------
interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

// --------------------------------------
// IERC165.sol (OpenZeppelin)
// --------------------------------------
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// --------------------------------------
// ERC165.sol (OpenZeppelin)
// --------------------------------------
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// --------------------------------------
// Strings.sol (OpenZeppelin)
// --------------------------------------
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) { return "0"; }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) { return "0x00"; }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) { length++; temp >>= 8; }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// --------------------------------------
// AccessControl.sol (OpenZeppelin)
// --------------------------------------
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// --------------------------------------
// ReentrancyGuard.sol (OpenZeppelin)
// --------------------------------------
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

/* -------- RageVault -------- */
contract RageVault {
    address public token;
    address public owner;
    constructor(address _token) {
        token = _token;
        owner = msg.sender;
    }
    function withdrawAll(address to) external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }
}

/* -------- RAGEHIPPO -------- */
contract RageHippo is ERC20, Ownable,  ReentrancyGuard, AccessControl {
    uint256 public maxSupply = 1_000_000_000_000 * 10 ** 18;
    uint256 public burnStopThreshold = 50_000_000_000 * 10 ** 18;
    uint256 public burnRate = 1; // 1%
    uint256 public mintRate = 15; // 1.5%
    uint256 public lastBurnTime;
    uint256 public lastMintTime;
    uint256 public constant burnInterval = 1 minutes;
    uint256 public constant mintInterval = 2 minutes;

    uint256 public txFeeRate = 2; // 2%
    uint256 public maxTxAmount = 10_000_000 * 10 ** 18;

    address public vault;
    bool public tradingEnabled = false;
    uint256 public launchBlock;

    mapping(address => bool) public blacklisted;
    mapping(address => bool) public isFeeExempt;

    event TradingEnabled(uint256 blockNumber);
    event BurnRateUpdated(uint256 newRate);
    event MintExecuted(uint256 amount);
    event VaultUpdated(address newVault);
    event BlacklistUpdated(address user, bool status);
    event AirdropExecuted(address[] recipients, uint256[] amounts);

    constructor() ERC20("RAGEHIPPO", "RAGE") {
        _mint(msg.sender, 690_000_000_000 * 10 ** 18);
        RageVault newVault = new RageVault(address(this));
        vault = address(newVault);
        lastBurnTime = block.timestamp;
        lastMintTime = block.timestamp;
    }

    modifier onlyWhenTradingEnabled(address sender) {
        require(tradingEnabled || sender == owner(), "Trading not enabled");
        _;
    }

    modifier notBlacklisted(address user) {
        require(!blacklisted[user], "Blacklisted address");
        _;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        override
        onlyWhenTradingEnabled(sender)
        notBlacklisted(sender)
        notBlacklisted(recipient)
    {
        require(amount <= maxTxAmount, "Transfer exceeds maxTxAmount");
        uint256 fee = (amount * txFeeRate) / 100;
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            fee = 0;
        }
        uint256 amountAfterFee = amount - fee;
        super._transfer(sender, recipient, amountAfterFee);
        if (fee > 0) {
            super._transfer(sender, vault, fee);
        }
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        launchBlock = block.number;
        emit TradingEnabled(launchBlock);
    }

    function burnRage() external onlyOwner {
        require(block.timestamp >= lastBurnTime + burnInterval, "Burn too early");
        require(totalSupply() > burnStopThreshold, "Burning stopped at 50B supply");

        uint256 amountToBurn = (totalSupply() * burnRate) / 100;
        if (totalSupply() - amountToBurn < burnStopThreshold) {
            amountToBurn = totalSupply() - burnStopThreshold;
        }
        _burn(owner(), amountToBurn);
        lastBurnTime = block.timestamp;
    }

    function mintRage() external onlyOwner {
        require(block.timestamp >= lastMintTime + mintInterval, "Mint too early");
        uint256 mintAmount = (totalSupply() * mintRate) / 1000;
        require(totalSupply() + mintAmount <= maxSupply, "Exceeds max supply");

        _mint(owner(), mintAmount);
        lastMintTime = block.timestamp;
        emit MintExecuted(mintAmount);
    }

    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatched arrays");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(owner(), recipients[i], amounts[i]);
        }
        emit AirdropExecuted(recipients, amounts);
    }

    function blacklist(address user, bool status) external onlyOwner {
        blacklisted[user] = status;
        emit BlacklistUpdated(user, status);
    }

    function setFeeExempt(address user, bool exempt) external onlyOwner {
        isFeeExempt[user] = exempt;
    }

    function updateBurnRate(uint256 newRate) external onlyOwner {
        require(newRate <= 5, "Burn rate too high");
        burnRate = newRate;
        emit BurnRateUpdated(newRate);
    }

    function updateMintRate(uint256 newRate) external onlyOwner {
        require(newRate <= 30, "Mint rate too high");
        mintRate = newRate;
    }

    function updateTxFeeRate(uint256 newRate) external onlyOwner {
        require(newRate <= 5, "Fee too high");
        txFeeRate = newRate;
    }

    function updateMaxSupply(uint256 newMax) external onlyOwner {
        require(newMax >= totalSupply(), "New max less than current supply");
        maxSupply = newMax;
    }

    function updateVault(address newVault) external onlyOwner {
        vault = newVault;
        emit VaultUpdated(newVault);
    }

    function updateMaxTxAmount(uint256 newLimit) external onlyOwner {
        require(newLimit >= 1_000_000 * 10 ** 18, "Too low");
        maxTxAmount = newLimit;
    }

    function getVaultBalance() public view returns (uint256) {
        return balanceOf(vault);
    }
}

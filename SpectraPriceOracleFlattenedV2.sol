// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20 ^0.8.22;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// src/interfaces/IDiscountModel.sol

interface IDiscountModel {
    /**
     * @notice Computes the discount factor for a given principal token.
     * @dev This function can be implemented customly, so not all argumnets need to be used
     *
     * @param initialImpliedAPY The initial implied APY of the principal token (in 18 decimals).
     * @param timeLeft The time remaining until maturity, in seconds.
     * @param futurePTValue The future value of the principal token at maturity.
     * @return discount The computed discount factor, expressed with futurePTValue's decimals precision.
     */
    function getDiscount(
        uint256 initialImpliedAPY,
        uint256 timeLeft,
        uint256 futurePTValue
    ) external pure returns (uint256 discount);

    /**
     * @notice Returns a human-readable description of the discount model.
     * @return A string describing the discount model.
     */
    function description() external pure returns (string memory);
}

// src/interfaces/IPrincipalToken.sol

interface IPrincipalToken {
    function getIBTRate() external view returns (uint256);
    function maturity() external view returns (uint256);
    function decimals() external view returns (uint8);
    function convertToUnderlying(uint256 principalAmount) external view returns (uint256);
    function underlying() external view returns (address);
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// src/SpectraPriceOracle.sol

contract SpectraPriceOracle is Ownable {
    uint256 private constant SECONDS_PER_YEAR = 365 days;
    uint256 private immutable UNIT;
    address public immutable PT;
    uint256 public immutable maturity;
    address public discountModel; // External discount model
    uint256 public initialImpliedAPY;
    uint8 private underlyingDecimals;

    event DiscountModelUpdated(address newModel);

    constructor(address _pt, address _discountModel, uint256 _initialImpliedAPY, address initOwner) Ownable(initOwner) {
        require(_pt != address(0), "zero address");
        PT = _pt;
        address underlying = IPrincipalToken(PT).underlying();
        underlyingDecimals = IERC20Metadata(underlying).decimals();
        maturity = IPrincipalToken(PT).maturity();
        discountModel = _discountModel;
        initialImpliedAPY = _initialImpliedAPY;
        UNIT = 10 ** IPrincipalToken(PT).decimals();

        uint256 timeLeft = ptTimeLeft();
        uint256 futurePTValue = IPrincipalToken(PT).convertToUnderlying(UNIT);
        require(getDiscount(timeLeft, futurePTValue) <= futurePTValue, "discount overflow");
    }

    function ptTimeLeft() public view returns (uint256) {
        return (maturity > block.timestamp) ? maturity - block.timestamp : 0;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        uint256 timeLeft = ptTimeLeft();

        uint256 futurePTValue = IPrincipalToken(PT).convertToUnderlying(UNIT);
        //Get the discount with the time left
        uint256 discount = getDiscount(timeLeft, futurePTValue);

        require(discount <= futurePTValue, "discount overflow");
        return (0, int256(futurePTValue - discount), 0, 0, 0);
    }

    function getDiscount(uint256 timeLeft, uint256 futurePTValue) public view returns (uint256) {
        return IDiscountModel(discountModel).getDiscount(initialImpliedAPY, timeLeft, futurePTValue);
    }

    /// @notice Update the discount model
    function setDiscountModel(address _newModel) external onlyOwner {
        require(_newModel != address(0), "zero discount model");
        discountModel = _newModel;
        emit DiscountModelUpdated(_newModel);
    }

    /// @notice Get the decimals of the asset
    function decimals() external view returns (uint8) {
        return underlyingDecimals;
    }
}

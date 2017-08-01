/*
A payable ERC20 token where payments are split according to token holdings.
The supply of this token is a constant of 100,000,000 which can intuitively
represent 100.000000% to be distributed to holders
https://github.com/o0ragman0o/PayableERC20 
*/
pragma solidity ^0.4.11;


contract RegBase{
    bytes32 constant public VERSION = "RegBase v0.2.4";

    /// @dev A static identifier, set in the constructor and used for registrar
    /// lookup
    /// @return Registrar name SandalStraps registrars
    bytes32 public regName;

    /// @dev An general purpose resource such as short text or a key to a
    /// string in a StringsMap
    /// @return resource
    bytes32 public resource;
    
    /// @dev An address permissioned to enact owner restricted functions
    /// @return owner
    address public owner;
    
    /// @dev An address permissioned to take ownership of the contract
    /// @return newOwner
    address public newOwner;

    // Triggered on change of owner address
    event ChangeOwner(address indexed newOwner);

    // Triggered on change of owner address
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

    // Triggered on change of resource
    event ChangedResource(bytes32 indexed resource);

    // Permits only the owner
    modifier onlyOwner() {require(msg.sender == owner);_;}

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for owner, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function RegBase(address _creator, bytes32 _regName, address _owner)
    {
        regName = _regName;
        owner = _owner != 0x0 ? _owner : 
                _creator != 0x0 ? _creator : msg.sender;
    }
    
    /// @notice Will selfdestruct the contract
    function destroy()
        public
        onlyOwner
    {
        selfdestruct(msg.sender);
    }
    
    /// @notice Initiate a change of owner to `_owner`
    /// @param _owner The address to which ownership is to be transfered
    function changeOwner(address _owner)
        public
        onlyOwner
        returns (bool)
    {
        ChangeOwner(_owner);
        newOwner = _owner;
        return true;
    }
    
    // @notice Finalise change of ownership to newOwner
    function acceptOwnership()
        public
        returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, msg.sender);
        owner = newOwner;
        delete newOwner;
        return true;
    }

    /// @notice Change the resource to `_resource`
    /// @param _resource A key or short text to be stored as the resource.
    function changeResource(bytes32 _resource)
        public
        onlyOwner
        returns (bool)
    {
        resource = _resource;
        ChangedResource(_resource);
        return true;
    }
}

contract Factory is Withdrawable, RegBase{

    // Deriving factories should have `bytes32 constant public regName` being
    // the product's contract name, e.g for products "Foo":
    // bytes32 constant public regName = "Foo";

    // Deriving factories should have `bytes32 constant public VERSION` being
    // the product's contract name appended with 'Factory` and the version
    // of the product, e.g for products "Foo":
    // bytes32 constant public VERSION "FooFactory 0.0.1";


    /// @return The payment in wei required to create the product contract.
    uint public value;

    // Is triggered when a product is created
    event Created(address creator, bytes32 regName, address addr);

    // To check that the correct fee has bene paid
    modifier feePaid() {
        require(msg.value == value || msg.sender == owner);
        _;
    }

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for _owner or _creator, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function Factory(address _creator, bytes32 _regName, address _owner)
        RegBase(_creator, _regName, _owner)
    {
        // nothing left to construct
    }
    
    /// @notice Set the product creation fee
    /// @param _fee The desired fee in wei
    function set(uint _fee) 
        onlyOwner
        returns (bool)
    {
        value = _fee;
        return true;
    }

    /// @notice Send contract balance to `owner`
    function withdraw(uint _value)
        public
        returns (bool)
    {
        owner.transfer(_value);
        return true;
    }

    /// @notice Create a new product contract
    /// @param _regName A unique name if the the product is to be registered in
    /// a SandalStraps registrar
    /// @param _owner An address of a third party owner.  Will default to
    /// msg.sender if 0x0
    /// @return kAddr_ The address of the new product contract
    function createNew(bytes32 _regName, address _owner) 
        payable returns(address kAddr_);
}


contract ReentryProtected{
    // The reentry protection state mutex.
    bool __reMutex;

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
        return;
    }

    // This modifier can be applied to public access state mutation functions
    // to protect against reentry if a `preventReentry` function has already
    // set the mutex. This prevents the contract from being reenter under a
    // different memory context which can break state variable integrity.
    modifier noReentry() {require(!__reMutex); _;}
}

contract WithdrawableAbstract{

    // Accept/decline payments switch state.
    bool public acceptingDeposits;

    // Triggered upon change to deposit acceptance state
    event AcceptingDeposits(bool indexed _accept);
    
    // Triggered upon receiving a deposit
    event Deposit(address indexed _from, uint _value);
    
    // Triggered upon a withdrawal
    event Withdrawal(address indexed _to, uint _value);
    
    // Trigger when a call to withdrawl from an external contract
    event WithdrawnFrom(address indexed _from, uint _value);

    modifier isAcceptingDeposits() {require(acceptingDeposits);_;}
    
    /// @param _addr An ethereum address
    /// @return The balance of ether held in the contract for `_addr`
    function etherBalanceOf(address _addr) constant returns (uint);
    
    /// @notice withdraw `_value` from account `msg.sender`
    /// @param _value the value to withdraw
    /// @return success
    function withdraw(uint _value) returns (bool);
    
    /// @notice withdraw `_value` from account `_addr`
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFor(address _addr, uint _value) returns (bool);
    
    /// @notice Withdraw `_value` from external contract at `_addr` to this
    /// this contract
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFrom(address _addr, uint _value) returns (bool);
    
    /// @notice Change the deposit acceptance state to `_accept`
    /// @param _accept Boolean acceptance state to change to
    /// @return State change success
    function acceptDeposits(bool _accept) public returns (bool);
}


// Example implimentation
contract Withdrawable is WithdrawableAbstract{
    // Withdrawable contracts should have an owner
    address public owner;

    function Withdrawable()
    {
        owner = msg.sender;
    }
    
    // Payable on condition that contract is accepting deposits
    function ()
        payable
        isAcceptingDeposits
    {
        Deposit(msg.sender, msg.value);
    }
    
    // Change deposit acceptance state
    function acceptDeposits(bool _accept)
        public
        returns (bool)
    {
        require(msg.sender == owner);
        acceptingDeposits = _accept;
        AcceptingDeposits(_accept);
        return true;
    }
    
    // Return an ether balance of an address
    function etherBalanceOf(address _addr)
        constant
        returns (uint)
    {
        return _addr == owner ? this.balance : 0;    
    }
    
    // Withdraw a value of ether awarded to the caller's address
    function withdraw(uint _value)
        public
        returns (bool)
    {
        require(etherBalanceOf(msg.sender) >= _value);
        msg.sender.transfer(_value);
        Withdrawal(owner, _value);
        return true;
    }
    
    // Push a payment to an address of which has awarded ether
    function withdrawFor(address _to, uint _value)
        public
        returns (bool)
    {
        require (msg.sender == owner);
        _to.transfer(_value);
        Withdrawal(_to, _value);
        return true;
    }
    
    // Withdraw ether from an external contract in which this instance holds a balance of ether
    function withdrawFrom(address _from, uint _value)
        public
        returns (bool)
    {
        WithdrawnFrom(_from, _value);
        return Withdrawable(_from).withdraw(_value);
    }
}

// ERC20 Standard Token Interface with safe maths and reentry protection
contract ERC20Interface{
    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value);

    /// @return The total supply of tokens
    function totalSupply() public constant returns (uint);
    
    // /// @return The trading symbol;
    function symbol() public constant returns (string);

    /// @param _addr The address of a token holder
    /// @return The amount of tokens held by `_addr`
    function balanceOf(address _addr) public constant returns (uint);

    /// @param _owner The address of a token holder
    /// @param _spender the address of a third-party
    /// @return The amount of tokens the `_spender` is allowed to transfer
    function allowance(address _owner, address _spender) public constant
        returns (uint);

    /// @notice Send `_amount` of tokens from `msg.sender` to `_to`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to transfer
    function transfer(address _to, uint256 _amount) public returns (bool);

    /// @notice Send `_amount` of tokens from `_from` to `_to` on the condition
    /// it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to transfer
    function transferFrom(address _from, address _to, uint256 _amount)
        public returns (bool);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the approved spender
    /// @param _amount The amount of tokens to transfer
    function approve(address _spender, uint256 _amount) public returns (bool);
}

contract ERC20Token is ReentryProtected, ERC20Interface{

    bytes32 constant public VERSION = "ERC20 0.4.4-o0ragman0o";

    // The Total supply of tokens
    uint totSupply;
    
    /// @return Token symbol
    string sym;
    
    // Token ownership mapping
    mapping (address => uint) balance;
    
    // Allowances mapping
    mapping (address => mapping (address => uint)) allowed;

   function ERC20Token(uint _supply, string _symbol){
        // Supply limited to 2^128 rather than 2^256 to prevent potential 
        // multiplication overflow
        require(_supply < 2**128);
        totSupply = _supply;
        sym = _symbol;
        balance[msg.sender] = totSupply;
    }
    
    function symbol()
        public
        constant
        returns (string)
    {
        return sym;
    }
    
    // Using an explicit getter allows for function overloading    
    function totalSupply()
        public
        constant
        returns (uint)
    {
        return totSupply;
    }
    
    // Using an explicit getter allows for function overloading    
    function balanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return balance[_addr];
    }
    
    // Using an explicit getter allows for function overloading    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint remaining_)
    {
        return allowed[_owner][_spender];
    }
        

    // Send _value amount of tokens to address _to
    // Reentry protection prevents attacks upon the state
    function transfer(address _to, uint256 _value)
        public
        noReentry
        returns (bool)
    {
        return xfer(msg.sender, _to, _value);
    }

    // Send _value amount of tokens from address _from to address _to
    // Reentry protection prevents attacks upon the state
    function transferFrom(address _from, address _to, uint256 _value)
        public
        noReentry
        returns (bool)
    {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _value;
        return xfer(_from, _to, _value);
    }

    // Process a transfer internally.
    function xfer(address _from, address _to, uint _value)
        internal
        returns (bool)
    {
        require(_value > 0 && _value <= balance[_from]);
        balance[_from] -= _value;
        balance[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    // Approves a third-party spender
    // Reentry protection prevents attacks upon the state
    function approve(address _spender, uint256 _value)
        public
        noReentry
        returns (bool)
    {
        require(balance[msg.sender] != 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract PayableERC20Interface {

    // 100.000000% supply
    uint constant TOTALSUPPLY = 100000000;

    bool public acceptingPayments;

    // The total ether deposits up to when a holder last triggered a claim
    uint deposits;
    
    // The contract balance when a holder last triggered a claim
    uint lastBalance;
    
    // Ether balances of token holders
    mapping (address => uint) etherBalance;
    
    // The paymentsToDate at the time of last claim for each holder 
    mapping (address => uint) lastClaimedAt;
    
/* Events */

    // Triggered when the contract recieves a payment
    event Deposit(uint value);
    
    // Triggered upon a withdrawal
    event Withdrawal(uint value);
    
    // Triggered when accepting payment state changes
    event AcceptingPayments(bool accepting);

    /// @notice Set the token symbol to `_symbol`. This can only be done once!
    /// @param _symbol The required token symbol
    /// @return success
    function setSymbol(string _symbol) returns (bool);

    /// @param _addr an account address
    /// @return The calculated balance of ether for `_addr`
    function etherBalanceOf(address _addr) constant returns (uint);

    /// @notice withdraw `_value` from account `msg.sender`
    /// @param _value the value to withdraw
    /// @return success
    function withdraw(uint _value) returns (bool);
    
    /// @notice withdraw `_value` from account `_addr`
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFor(address _addr, uint _value) returns (bool);
    
    /// @notice Withdraw `_value` from external contract at `_addr` to this
    /// this contract
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFrom(address _addr, uint _value) returns (bool);

    /// @notice Change accept payments to `_accept`
    /// @param _accept a bool for the required acceptance state
    /// @return success
    function acceptPayments(bool _accept) returns (bool);
}

contract PayableERC20 is ERC20Token, RegBase, PayableERC20Interface
{
/* Constants */
    
    bytes32 public constant VERSION = "PayableERC20 v0.3.0";

/* Functions Public non-constant*/

    function PayableERC20(address _creator, bytes32 _regName, address _owner)
        RegBase(_creator, _regName, _owner)
        ERC20Token(100000000, "")
    {
        _creator = _creator == 0x0 ? owner : _creator;
        acceptingPayments = true;
    }

    function() 
        payable
    {
        require(acceptingPayments && msg.value > 0);
        Deposit(msg.value);
    }
    
    /// @notice Will selfdestruct the contract on the condition it has zero balance

    function destroy()
        public
        onlyOwner
    {
        // must flush all ether balances first. But remainders may have
        // accumulated  under 100,000,000 wei
        require(this.balance <= 100000000);
        selfdestruct(msg.sender);
    }

    function setSymbol(string _symbol)
        onlyOwner
        returns (bool)
    {
        require(bytes(symbol).length == 0);
        symbol = _symbol;
        return true;
    }

    function acceptPayments(bool _accept)
        public
        onlyOwner
        returns (bool)
    {
        acceptingPayments = _accept;
        return true;
    }

    // Overload the ERC20 xfer() to account for unclaimed ether
    function xfer(address _from, address _to, uint _value)
        internal
        returns (bool)
    {
        require(_value > 0 && _value <= balance[_from]);
        
        // Update party's outstanding claims
        claimPaymentsFor(_from);
        claimPaymentsFor(_to);
        
        // Transfer tokens
        balance[_from] -= _value;
        balance[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function etherBalanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return etherBalance[_addr] + claimablePayments(_addr);
    }
    
    // Withdraw an amount of the sender's ether balance
    function withdraw(uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(msg.sender, _value);
    }
    
    // Withdraw on behalf of a balance holder
    function withdrawFor(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(_addr, _value);
    }
    
    // Withdraw from an external contract in which this contract has a balance.
    // Reentry is prevented to all but the default function to recieve payment.
    function withdrawFrom(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return WithdrawableInterface(_addr).withdraw(_value);
    }
    
    function intlWithdraw(address _addr, uint _value)
        internal
        returns (bool)
    {
        // Cache state values manipulate rather than re-writes
        // across a number of functions
        uint lastBal = lastBalance;
        uint ethBal = etherBalance[_addr];
        uint claim;
        
        // Check for unprocessed deposits
        if (this.balance > lastBal) {
            deposits += this.balance - lastBal;
            lastBal = this.balance;
        }

        // claimPaymentsFor(_addr);
        ethBal += balance[_addr] * (deposits - lastClaimedAt[_addr]) /
            TOTALSUPPLY;
        lastClaimedAt[_addr] = deposits;

        // check balance and withdraw on valid amount
        require(_value <= ethBal);
        etherBalance[_addr] = ethBal - _value;
        // lastBalance = this.balance - _value;
        lastBalance = lastBal - _value;
        Withdrawal(_value);
        _addr.transfer(_value);
        return true;
    }

    function paymentsToDate()
        public
        constant
        returns (uint)
    {
        return deposits + (this.balance - lastBalance); 
    }

    function updateDeposits()
        internal
    {
        // Update recent deposits
        uint lb = lastBalance;
        if (this.balance > lb) {
            deposits += this.balance - lb;
            lastBalance = this.balance;
        }
    }
    
    function claimPaymentsFor(address _addr)
        internal
    {
        updateDeposits();
        // Update accounts ether balance
        uint claim = claimablePayments(_addr);
        lastClaimedAt[_addr] = deposits;
        if (claim > 0) {
            etherBalance[_addr] += claim;
        }
    }

    function claimablePayments(address _addr)
        internal
        constant
        returns (uint)
    {
        // token balance * amount since last claim / supply
        return (balance[_addr] * (paymentsToDate() - lastClaimedAt[_addr])) /
            TOTALSUPPLY;
    }
}


contract PayableERC20Factory is Factory{
    bytes32 constant public regName = "PayableERC20";
    bytes32 constant public VERSION = "PayableERC20Factory v0.3.0";

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for _owner or _creator, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function PayableERC20Factory(address _creator, bytes32 _regName, address _owner)
        Factory(_creator, _regName, _owner)
    {
        // nothing to construct
    }

    /// @notice Create a new product contract
    /// @param _regName A unique name if the the product is to be registered in
    /// a SandalStraps registrar
    /// @param _owner An address of a third party owner.  Will default to
    /// msg.sender if 0x0
    /// @return kAddr_ The address of the new product contract
    function createNew(bytes32 _regName, address _owner)
        payable
        feePaid
        returns(address kAddr_)
    {
        require(_regName != 0x0);
        _owner = _owner == 0x0 ? msg.sender : _owner;
        _regName = _regName == 0x0 ? regName | bytes32(now) : _regName;
        kAddr_ = address(new PayableERC20(owner, _regName, _owner));
        Created(msg.sender, _regName, kAddr_);
    }
}
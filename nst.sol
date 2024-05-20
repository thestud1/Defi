// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nrBurnt;
    mapping(address => string) public badge;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(_decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function _getBadge(address _account) private {
        uint256 temp = nrBurnt[_account];
        if (temp < (100* 10 ** uint256(decimals))) {
            badge[_account] = "Spark Starter";
        } else if (temp < (500* 10 ** uint256(decimals))) {
            badge[_account] = "Flame Fanatic";
        } else if (temp < (2000* 10 ** uint256(decimals))) {
            badge[_account] = "Blaze Bringer";
        } else if (temp < (5000* 10 ** uint256(decimals))) {
            badge[_account] = "Inferno Initiate";
        } else {
            badge[_account] = "Phoenix Master";
        }
    }

    function tokenBurn(uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[msg.sender], "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        nrBurnt[msg.sender] += _value;
        _getBadge(msg.sender);
        emit Transfer(msg.sender, address(0), _value); // Emit transfer to the zero address
        return true;
    }
}

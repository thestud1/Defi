// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./FactoryI.sol";
// import "https://github.com/LuluKiffer/DefiClass/blob/main/interfaces/IRouter.sol";
// import "https://github.com/LuluKiffer/DefiClass/blob/main/interfaces/IPair.sol";
// import "https://github.com/LuluKiffer/DefiClass/blob/main/interfaces/IERC20.sol";

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
interface IPair{
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value,  uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
} 




contract Wechselkurs {
    IFactory public factory;
    IRouter public router;

    constructor() {
        factory = IFactory(0x0Ca73866dFf0f6b0508F5Cbb223C857C19463e07);
        router = IRouter(0x5DA88dF55AF2E5681D33f36e5916d63797BF4766);
    }

    function getWechselkurs(uint256 amountIn, IERC20 tokenA, IERC20 tokenB) public view returns (uint256) {
        // Get the pair address from the factory
        address pairAddress = factory.getPair(address(tokenA), address(tokenB));
        require(pairAddress != address(0), "Pair does not exist");

        // Initialize the pair interface
        IPair pair = IPair(pairAddress);

        // Get decimals for both tokens
        // uint8 decimalsA = tokenA.decimals();
        // uint8 decimalsB = tokenB.decimals();

        // Get the reserves from the pair
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        uint256 reserveA;
        uint256 reserveB;

        // Determine which token is token0 and which is token1, and assign reserves accordingly
        if (pair.token0() == address(tokenA)) {
            reserveA = reserve0;
            reserveB = reserve1;
        } else {
            reserveA = reserve1;
            reserveB = reserve0;
        }

        // Calculate the output amount using the router's getAmountOut function
        if(reserveA>0 && reserveB>0){
        uint amountOut = router.getAmountOut(amountIn, reserveA, reserveB);
        return amountOut;
        }
        // Adjust the output amount by the decimals of tokenB
        return 0;
    }
}


contract PairGetter {
    IFactory public factory;
    IRouter public router;
    address weth = 0xDE39C89e7A8E3Fc73e1e7f8b2edecD4c7FE62b66;
    address defi = 0xE5873093edA4e64b77C80186aDC5be024444fcbd;
    mapping(address => address[2]) public pairs;
    mapping(address => bool) exists;
    mapping(uint256 => address) public uniqueAddresses;
    uint256 public ind = 0;
    uint256 public ActualPairs = 0;
    constructor() {
        factory = IFactory(0x0Ca73866dFf0f6b0508F5Cbb223C857C19463e07);
        router = IRouter(0x5DA88dF55AF2E5681D33f36e5916d63797BF4766);
    }

    function getAllPairs() public returns (bool) {
        uint256 length = factory.allPairsLength();
        ind = 0;
        ActualPairs = 0;
        for (uint256 i = 0; i < length; i++) {
            IPair pairAddress = IPair(factory.allPairs(i));
            address token0 = pairAddress.token0();
            address token1 = pairAddress.token1();

            if (token0 != weth && token0 != defi && !exists[token0]) {
                exists[token0] = true;
                uniqueAddresses[ind] = token0;
                ind++;
            }
            if (token1 != weth && token1 != defi && !exists[token1]) {
                exists[token1] = true;
                uniqueAddresses[ind] = token1;
                ind++;
            }
        }
        
        for (uint256 i = 0; i < ind; i++) {
            address pair0 = factory.getPair(uniqueAddresses[i], weth);
            address pair1 = factory.getPair(uniqueAddresses[i], defi);

            if (pair0 != address(0) && pair1 != address(0)) {
                pairs[uniqueAddresses[i]][0] = pair0;
                pairs[uniqueAddresses[i]][1] = pair1;
                
                ActualPairs++;
            }else{
                uniqueAddresses[i] = address(0);
            }
        }

        return true;
    }
}

contract GetExchangeRate {
    PairGetter public pairGetter;
    IFactory public factory;
    IRouter public router;
    Wechselkurs public wechselkurs;
    address public weth = 0xDE39C89e7A8E3Fc73e1e7f8b2edecD4c7FE62b66;
    address public defi = 0xE5873093edA4e64b77C80186aDC5be024444fcbd;
    uint256 public ETH = 1 ether;
    uint256[] public EXrate;

    constructor() {
        factory = IFactory(0x0Ca73866dFf0f6b0508F5Cbb223C857C19463e07);
        router = IRouter(0x5DA88dF55AF2E5681D33f36e5916d63797BF4766);       
        pairGetter = PairGetter(0xAe3Dfd7219F489db56a4AC51dca613a3F9A282b2);
        wechselkurs = Wechselkurs(0x3466EeC48Ec873007F8457f506B631bbDeC19eB1);
    }

    function getExRates() public returns (bool) {
        delete EXrate;
        uint256 ind = pairGetter.ind(); // Get the latest ind value each time

        for (uint256 i = 0; i < ind; i++) {
            
            address middleCoin = pairGetter.uniqueAddresses(i);

            if(middleCoin!=address(0)){
            uint256 ex1 = wechselkurs.getWechselkurs(ETH, IERC20(weth), IERC20(middleCoin));
            if(ex1!=0){
                uint256 ex2 = wechselkurs.getWechselkurs(ex1, IERC20(middleCoin), IERC20(defi));
                EXrate.push(ex2);
            }
            }
        }
        return true;
    }

    function getBestExRates() public view returns(uint256){
        uint256 ind = EXrate.length;
        uint256 max = 0;
        for(uint256 i = 0; i<ind; i++){
            if(EXrate[i]>max){
                max = EXrate[i];
            }
        }
        return max;
    }
}





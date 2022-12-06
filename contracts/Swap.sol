// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    
    address testingTokenAddress;

    constructor(address _testingToken) ERC20("TestingLP","TLP"){
        require(_testingToken != address(0),"This is a null address");
        testingTokenAddress = _testingToken;
    }

    function getReserves() public view returns(uint) {
        return ERC20(testingTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint _amount) public payable returns(uint){
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint testingReserve = getReserves();
        ERC20 testingsToken = ERC20(testingTokenAddress);

        if(testingReserve == 0){
            testingsToken.transferFrom(msg.sender, address(this), _amount);

            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        }
        else{
            uint ethReserve = ethBalance - msg.value;
            uint testingTokenAmount = (msg.value * testingReserve)/(ethReserve); // that the user can add
            require(_amount >= testingTokenAmount, "Amount is less then the required token amount");

            testingsToken.transferFrom(msg.sender, address(this), testingTokenAmount);
            liquidity = (msg.value * totalSupply())/(ethReserve);
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns(uint, uint){
        require(_amount > 0, "The amount should be greater then zero!");

        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();

        uint ethAmount = (_amount * ethReserve)/(_totalSupply);
        uint testingTokenAmount = (_amount * getReserves())/(_totalSupply);

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);

        ERC20(testingTokenAddress).transfer(msg.sender, testingTokenAmount);
        return (ethAmount, testingTokenAmount);
    }

    function getAmountOfTokens(
     uint256 inputAmount,
     uint256 inputReserve,
     uint256 outputReserve) public pure returns(uint256){

        require(inputReserve > 0 && outputReserve > 0, "Insufficient Resourses");

        uint256 inputAmountWithFees = ((inputAmount)*99)/100;

        uint256 numerator = outputReserve * inputAmountWithFees; // Δy = (y * Δx) / (x + Δx)
        uint256 denomirator = inputReserve + inputAmountWithFees;

        return numerator / denomirator;
    }

    function ethToTestingToken(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserves();

        uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value , tokenReserve);

        require(tokensBought >= _minTokens, "Insuffient Balance!");
        ERC20(testingTokenAddress).transfer(msg.sender, tokensBought);
    }

    function testingTokenToEth(uint256 _tokensSold, uint _minTokens) public payable {
        uint256 tokenReserve = getReserves();

        uint256 ethBought = getAmountOfTokens(_tokensSold, tokenReserve, address(this).balance);

        require(ethBought >= _minTokens, "Insuffient Balance!");
        payable(msg.sender).transfer(ethBought); 
    }
}
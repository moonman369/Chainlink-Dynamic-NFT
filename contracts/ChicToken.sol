// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChicToken is ERC20, Ownable {

    constructor (uint256 _totalSupplyExclDecimal, address _tokenMintAddress) ERC20 ("ChicToken", "CHIC") {
        _mint(_tokenMintAddress, _totalSupplyExclDecimal * 10 ** decimals());
    }

}
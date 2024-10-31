// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollateralFacet {
    

    function collateralizeNFT(address nftContract, uint256 tokenId) external;

    function releaseNFT(uint256 loanId) external;
}

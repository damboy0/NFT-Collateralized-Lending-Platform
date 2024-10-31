// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollateralFacet {
    event NFTCollateralized(uint256 loanId, address borrower, address nftContract, uint256 tokenId);
    event NFTReleased(uint256 loanId, address borrower);

    function collateralizeNFT(address nftContract, uint256 tokenId) external;

    function releaseNFT(uint256 loanId) external;
}

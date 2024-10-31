// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";
import "../interfaces/ICollateralFacet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CollateralFacet is ICollateralFacet {
    event NFTCollateralized(uint256 loanId, address borrower, address nftContract, uint256 tokenId);
    event NFTReleased(uint256 loanId, address borrower);

    function collateralizeNFT(address nftContract, uint256 tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(!ds.isNFTCollateralized[nftContract][tokenId], "NFT already collateralized");

        // Transfer NFT to the contract
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);

        // Increment loan counter and set up new loan
        uint256 loanId = ds.loanCounter++;
        ds.loans[loanId] = LibDiamond.Loan({
            borrower: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            loanAmount: 0,
            interestRate: 0,
            duration: 0,
            startTime: 0,
            isRepaid: false
        });

        ds.isNFTCollateralized[nftContract][tokenId] = true;
        ds.borrowerLoans[msg.sender].push(loanId);

        emit NFTCollateralized(loanId, msg.sender, nftContract, tokenId);
    }

    function releaseNFT(uint256 loanId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.Loan storage loan = ds.loans[loanId];

        require(msg.sender == loan.borrower, "Only borrower can release");
        require(loan.isRepaid, "Loan not repaid");

        // Release the NFT back to borrower
        IERC721(loan.nftContract).safeTransferFrom(address(this), loan.borrower, loan.tokenId);
        ds.isNFTCollateralized[loan.nftContract][loan.tokenId] = false;

        emit NFTReleased(loanId, loan.borrower);
    }
}

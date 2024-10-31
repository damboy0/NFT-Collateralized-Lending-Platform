// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/facets/LoanFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/facets/ERC721Facet.sol";
import "../contracts/libraries/LibDiamond.sol";


contract LoanFacetTest is Test {
    LoanFacet loanFacet;
    ERC20Facet mockToken;
    ERC721Facet erc721Facet;
    address nftContract;
    uint256 tokenId = 1;

   function setUp() public {
        loanFacet = new LoanFacet();
        mockToken = new ERC20Facet("MockToken", "MTK", 18);
        erc721Facet = new ERC721Facet("MockNFT", "MNFT");
        
        // Assign nftContract to the address of the ERC721Facet
        nftContract = address(erc721Facet); 

        // Mint an NFT and mock tokens
        erc721Facet.mint(address(this)); 
        tokenId = 0; // The first minted tokenId is 0
        mockToken.mint(address(this), 1000 * 10 ** 18);
        erc721Facet.approve(address(loanFacet), tokenId);
}

    function testCreateLoan() public {
    // Approve the NFT and tokens for the loan
    // ERC721Facet(nftContract).approve(address(loanFacet), tokenId); // tokenId is now 0
    // mockToken.approve(address(loanFacet), 1000 * 10 ** 18);

    // Call createLoan
    uint256 loanAmount = 500 * 10 ** 18;
    uint256 interestRate = 500; // 5%
    uint256 duration = 30 days;
    uint256 loanId = loanFacet.createLoan(nftContract, tokenId, loanAmount, interestRate, duration);

    // Check loan details
    (address borrower, , , uint256 loanAmount_, uint256 interestRate_, uint256 duration_, , bool isRepaid) = loanFacet.getLoanDetails(loanId);

    assertEq(borrower, address(this));
    assertEq(loanAmount_, loanAmount);
    assertEq(interestRate_, interestRate);
    assertEq(duration_, duration);
    assertTrue(!isRepaid);
}

function testRepayLoan() public {
    // Set up loan by collateralizing NFT
    ERC721Facet(nftContract).approve(address(loanFacet), tokenId); // tokenId is now 0
    loanFacet.createLoan(nftContract, tokenId, 500 * 10 ** 18, 500, 30 days);

    // Approve token for repayment
    uint256 loanId = LibDiamond.diamondStorage().borrowerLoans[address(this)][0];
    uint256 repaymentAmount = loanFacet.calculateRepayment(loanId);
    mockToken.approve(address(loanFacet), repaymentAmount);

    // Repay loan
    loanFacet.repayLoan(loanId);

    // Verify loan is repaid and NFT is released
    ( , , , , , , , bool isRepaid) = loanFacet.getLoanDetails(loanId);
    assertTrue(isRepaid);
}
}

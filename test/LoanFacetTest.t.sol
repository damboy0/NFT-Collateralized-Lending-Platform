// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/facets/LoanFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/facets/ERC721Facet.sol";
import "../contracts/libraries/LibDiamond.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract LoanFacetTest is Test {
    LoanFacet loanFacet;
    IERC20 mockToken;
    address nftContract;
    uint256 tokenId = 1;

    function setUp() public {
        loanFacet = new LoanFacet();
        mockToken = new ERC20Facet("MockToken", "MTK", 18);
        nftContract = address(new ERC721Facet());

        // Mint an NFT and mock tokens
        ERC721Facet(nftContract).mint(address(this), tokenId);
        mockToken.mint(address(this), 1000 * 10 ** 18);

        // Initialize loan token
        loanFacet.initializeLoanToken(address(mockToken));
    }

    function testCreateLoan() public {
        // Approve the NFT and tokens for the loan
        ERC721Facet(nftContract).approve(address(loanFacet), tokenId);
        mockToken.approve(address(loanFacet), 1000 * 10 ** 18);

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
        MockNFT(nftContract).approve(address(loanFacet), tokenId);
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

// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "../contracts/facets/CollateralFacet.sol";
// import "../contracts/facets/LoanFacet.sol";
// import "../contracts/libraries/LibDiamond.sol"; // Ensure this path is correct
// // import "../contracts/interfaces/IDiamondCut.sol"; // Ensure this path is correct
// import "../contracts/facets/DiamondCutFacet.sol";
// import "../contracts/Diamond.sol"; // Ensure this path is correct
// import "./helpers/DiamondUtils.sol"; // Ensure this path is correct

// contract LoanCollateralFacetTest is Test {
//     Diamond diamond;
//     CollateralFacet collateralFacet;
//     LoanFacet loanFacet;
//     IERC20 mockToken;
//     address nftContract; // Mock NFT contract address
//     uint256 tokenId = 1; // Sample token ID for testing

//     function setUp() public {
//         // Deploy a mock ERC20 token
//         mockToken = new MockERC20("MockToken", "MTK", 18);

//         // Deploy diamond and facets
//         diamond = new Diamond(address(this), address(new DiamondCutFacet()));
//         collateralFacet = new CollateralFacet();
//         loanFacet = new LoanFacet();

//         // Upgrade diamond with facets
//         FacetCut;
//         cut[0] = FacetCut({
//             facetAddress: address(collateralFacet),
//             action: FacetCutAction.Add,
//             functionSelectors: generateSelectors("CollateralFacet")
//         });
//         cut[1] = FacetCut({
//             facetAddress: address(loanFacet),
//             action: FacetCutAction.Add,
//             functionSelectors: generateSelectors("LoanFacet")
//         });
        
//         IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

//         // Assume we have deployed a mock NFT contract
//         nftContract = address(new MockNFT());
//     }

//     function testCollateralizeNFT() public {
//         // Mint an NFT to the caller
//         MockNFT(nftContract).mint(address(this), tokenId);

//         // Approve the NFT for the collateral facet
//         MockNFT(nftContract).approve(address(diamond), tokenId);

//         // Call collateralizeNFT
//         CollateralFacet(address(diamond)).collateralizeNFT(nftContract, tokenId);

//         // Check if the NFT is marked as collateralized
//         assertTrue(LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId]);
//     }

//     function testCreateLoan() public {
//         // Mint and approve the NFT
//         MockNFT(nftContract).mint(address(this), tokenId);
//         MockNFT(nftContract).approve(address(diamond), tokenId);

//         // Collateralize the NFT first
//         CollateralFacet(address(diamond)).collateralizeNFT(nftContract, tokenId);

//         // Initialize the loan token
//         loanFacet.initializeLoanToken(address(mockToken));

//         // Create a loan
//         uint256 loanAmount = 1000 * 10 ** 18; // 1000 tokens
//         uint256 interestRate = 500; // 5%
//         uint256 duration = 30 days;

//         mockToken.mint(address(this), loanAmount); // Mint tokens for testing
//         mockToken.approve(address(diamond), loanAmount);

//         uint256 loanId = LoanFacet(address(diamond)).createLoan(nftContract, tokenId, loanAmount, interestRate, duration);

//         // Check loan details
//         (address borrower, address nftContract_, uint256 tokenId_, uint256 loanAmount_, uint256 interestRate_, uint256 duration_, uint256 startTime, bool isRepaid) = LoanFacet(address(diamond)).getLoanDetails(loanId);

//         assertEq(borrower, address(this));
//         assertEq(nftContract_, nftContract);
//         assertEq(tokenId_, tokenId);
//         assertEq(loanAmount_, loanAmount);
//         assertEq(interestRate_, interestRate);
//         assertEq(duration_, duration);
//         assertEq(isRepaid, false);
//     }

//     function testRepayLoan() public {
//         // Mint and approve the NFT
//         MockNFT(nftContract).mint(address(this), tokenId);
//         MockNFT(nftContract).approve(address(diamond), tokenId);
//         CollateralFacet(address(diamond)).collateralizeNFT(nftContract, tokenId);

//         // Initialize the loan token
//         loanFacet.initializeLoanToken(address(mockToken));

//         // Create a loan
//         uint256 loanAmount = 1000 * 10 ** 18; // 1000 tokens
//         uint256 interestRate = 500; // 5%
//         uint256 duration = 30 days;
//         mockToken.mint(address(this), loanAmount);
//         mockToken.approve(address(diamond), loanAmount);
//         uint256 loanId = LoanFacet(address(diamond)).createLoan(nftContract, tokenId, loanAmount, interestRate, duration);

//         // Calculate repayment amount and mint tokens
//         uint256 repaymentAmount = LoanFacet(address(diamond)).calculateRepayment(loanId);
//         mockToken.mint(address(this), repaymentAmount);
//         mockToken.approve(address(diamond), repaymentAmount);

//         // Repay the loan
//         LoanFacet(address(diamond)).repayLoan(loanId);

//         // Verify loan is marked as repaid
//         (,, ,,, ,,, bool isRepaid) = LoanFacet(address(diamond)).getLoanDetails(loanId);
//         assertTrue(isRepaid);

//         // Verify NFT is released back to the borrower
//         assertFalse(LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId]);
//     }

//     function testReleaseNFT() public {
//         // Mint and approve the NFT
//         MockNFT(nftContract).mint(address(this), tokenId);
//         MockNFT(nftContract).approve(address(diamond), tokenId);
//         CollateralFacet(address(diamond)).collateralizeNFT(nftContract, tokenId);

//         // Initialize the loan token
//         loanFacet.initializeLoanToken(address(mockToken));

//         // Create a loan
//         uint256 loanAmount = 1000 * 10 ** 18; // 1000 tokens
//         uint256 interestRate = 500; // 5%
//         uint256 duration = 30 days;
//         mockToken.mint(address(this), loanAmount);
//         mockToken.approve(address(diamond), loanAmount);
//         uint256 loanId = LoanFacet(address(diamond)).createLoan(nftContract, tokenId, loanAmount, interestRate, duration);

//         // Repay the loan
//         uint256 repaymentAmount = LoanFacet(address(diamond)).calculateRepayment(loanId);
//         mockToken.mint(address(this), repaymentAmount);
//         mockToken.approve(address(diamond), repaymentAmount);
//         LoanFacet(address(diamond)).repayLoan(loanId);

//         // Now release the NFT
//         CollateralFacet(address(diamond)).releaseNFT(loanId);

//         // Verify NFT is released
//         assertFalse(LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId]);
//     }

//     // Additional tests to check revert conditions, etc. can be added similarly.
// }

// // Mock contracts for testing

// contract MockERC20 is IERC20 {
//     // Implement ERC20 methods here for testing (balanceOf, transfer, mint, etc.)
// }

// contract MockNFT is IERC721 {
//     // Implement ERC721 methods here for testing (mint, approve, transfer, etc.)
// }

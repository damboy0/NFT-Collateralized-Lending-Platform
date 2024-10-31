// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ILoanFacet.sol";
import "../libraries/LibDiamond.sol";

contract LoanFacet is ILoanFacet {
    IERC20 public loanToken; // ERC20 token used for lending (e.g., USDC, DAI)
    uint256 public loanCounter; // Counter for unique loan IDs

    event LoanCreated(
        uint256 indexed loanId,
        address indexed borrower,
        address nftContract,
        uint256 tokenId,
        uint256 loanAmount,
        uint256 interestRate,
        uint256 duration
    );

    event LoanRepaid(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 repaymentAmount
    );

    event CollateralReleased(
        uint256 indexed loanId,
        address indexed borrower,
        address nftContract,
        uint256 tokenId
    );

    function initializeLoanToken(address _tokenAddress) external {
        require(address(loanToken) == address(0), "Token already initialized");
        loanToken = IERC20(_tokenAddress);
    }

    function createLoan(
        address nftContract,
        uint256 tokenId,
        uint256 loanAmount,
        uint256 interestRate, // Interest rate in basis points (1% = 100)
        uint256 duration // Duration of loan in seconds
    ) external returns (uint256 loanId) {
        require(
            !LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId],
            "NFT already collateralized"
        );

        // Transfer NFT from borrower to contract as collateral
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        
        // Increment the loan counter and set the loan ID
        loanId = LibDiamond.diamondStorage().loanCounter++;
        
        // Create loan struct and store in mapping
        LibDiamond.diamondStorage().loans[loanId] = LibDiamond.Loan({
            borrower: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            loanAmount: loanAmount,
            interestRate: interestRate,
            duration: duration,
            startTime: block.timestamp,
            isRepaid: false
        });
        
        // Mark NFT as collateralized
        LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId] = true;

        // Record loan ID for the borrower (allows tracking multiple loans)
        LibDiamond.diamondStorage().borrowerLoans[msg.sender].push(loanId);
        
        // Transfer loan tokens to the borrower
        require(
            loanToken.transfer(msg.sender, loanAmount),
            "Token transfer failed"
        );

        emit LoanCreated(
            loanId,
            msg.sender,
            nftContract,
            tokenId,
            loanAmount,
            interestRate,
            duration
        );
    }

    function calculateRepayment(uint256 loanId) public view returns (uint256) {
        LibDiamond.Loan memory loan = LibDiamond.diamondStorage().loans[loanId];
        require(!loan.isRepaid, "Loan already repaid");

        // Calculate interest based on duration and interest rate
        uint256 interest = (loan.loanAmount * loan.interestRate * loan.duration) /
            (365 days * 10000); // interest rate in basis points (e.g., 5% = 500)
        return loan.loanAmount + interest;
    }

    function repayLoan(uint256 loanId) external {
        LibDiamond.Loan storage loan = LibDiamond.diamondStorage().loans[loanId];
        require(msg.sender == loan.borrower, "Not the borrower");
        require(!loan.isRepaid, "Loan already repaid");

        // Calculate the repayment amount (principal + interest)
        uint256 repaymentAmount = calculateRepayment(loanId);

        // Transfer repayment amount from borrower to contract
        require(
            loanToken.transferFrom(msg.sender, address(this), repaymentAmount),
            "Repayment transfer failed"
        );

        // Mark the loan as repaid and release the NFT collateral
        loan.isRepaid = true;
        IERC721(loan.nftContract).transferFrom(address(this), loan.borrower, loan.tokenId);

        // Remove NFT from collateralized list
        LibDiamond.diamondStorage().isNFTCollateralized[loan.nftContract][loan.tokenId] = false;

        emit LoanRepaid(loanId, msg.sender, repaymentAmount);
        emit CollateralReleased(loanId, msg.sender, loan.nftContract, loan.tokenId);
    }

    function getLoanDetails(uint256 loanId)
        external
        view
        returns (
            address borrower,
            address nftContract,
            uint256 tokenId,
            uint256 loanAmount,
            uint256 interestRate,
            uint256 duration,
            uint256 startTime,
            bool isRepaid
        )
    {
        LibDiamond.Loan storage loan = LibDiamond.diamondStorage().loans[loanId];
        return (
            loan.borrower,
            loan.nftContract,
            loan.tokenId,
            loan.loanAmount,
            loan.interestRate,
            loan.duration,
            loan.startTime,
            loan.isRepaid
        );
    }
    
    function getBorrowerLoans(address borrower) external view returns (uint256[] memory) {
        return LibDiamond.diamondStorage().borrowerLoans[borrower];
    }
    
    function isNFTInCollateral(address nftContract, uint256 tokenId) external view returns (bool) {
        return LibDiamond.diamondStorage().isNFTCollateralized[nftContract][tokenId];
    }
}

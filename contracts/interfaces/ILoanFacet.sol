// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILoanFacet {
    // event LoanCreated(
    //     uint256 indexed loanId,
    //     address indexed borrower,
    //     address nftContract,
    //     uint256 tokenId,
    //     uint256 loanAmount,
    //     uint256 interestRate,
    //     uint256 duration
    // );

    // event LoanRepaid(
    //     uint256 indexed loanId,
    //     address indexed borrower,
    //     uint256 repaymentAmount
    // );

    // event CollateralReleased(
    //     uint256 indexed loanId,
    //     address indexed borrower,
    //     address nftContract,
    //     uint256 tokenId
    // );

    function initializeLoanToken(address _tokenAddress) external;

    function createLoan(
        address nftContract,
        uint256 tokenId,
        uint256 loanAmount,
        uint256 interestRate,
        uint256 duration
    ) external returns (uint256 loanId);

    function calculateRepayment(uint256 loanId) external view returns (uint256);

    function repayLoan(uint256 loanId) external;

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
        );

    function getBorrowerLoans(address borrower) external view returns (uint256[] memory);

    function isNFTInCollateral(address nftContract, uint256 tokenId) external view returns (bool);
}

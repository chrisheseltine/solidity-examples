pragma solidity ^0.4.0;

contract OrganisationInterface {

  function setDataStore(address _tokenLedger, address _eternalStorage);

  function addProposal(bytes32 _name);

  function proposalsCount() constant returns (uint256);

  function getProposal(uint256 _id) constant returns (bytes32 _name, uint256 _eth);

  function updateProposal(uint256 _id, bytes32 _name);

  function fundProposal(uint256 _id);

  function setProposalFund(uint256 _id, uint256 _eth);

  function generateTokens(uint256 _amount);

  function getBalance(address _account) constant returns (uint256);

  function setTokenLedgerAddress(address _tokenLedger);

  function kill(address upgradedOrganisation_);
  
}

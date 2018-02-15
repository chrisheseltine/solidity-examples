pragma solidity ^0.4.0;

import "OrganisationInterface.sol";
import "TokenLedger.sol";
import "EternalStorage.sol";
import "SecurityLibrary.sol";

contract Parent {

  event OrganisationCreated(address organisation, uint now);
  event OrganisationUpgraded(address organisation, uint now);

  using SecurityLibrary for EternalStorage;

  mapping(bytes32 => address) public organisations;

  function registerOrganisation(bytes32 key_, address orgAddress)
  {
    var tokenLedger = new TokenLedger();
    var eternalStorage = new EternalStorage();
    // Set the calling user as the first colony admin
    eternalStorage.addAdmin(msg.sender);

    OrganisationInterface(orgAddress).setDataStore(tokenLedger, eternalStorage);
    // Set the organisation as the storage owner
    eternalStorage.changeOwner(orgAddress);

    organisations[key_] = orgAddress;
    OrganisationCreated(organisation, now);
  }

  function getOrganisation(bytes32 key_) constant returns (address)
  {
    return organisations[key_];
  }

  function upgradeOrganisation(bytes32 key_, address newOrgAddress)
  {
    address organisationAddress = organisations[key_];
    var organisation = Organisation(organisationAddress);
    var tokenLedger = organisation.tokenLedger();
    var eternalStorage = organisation.eternalStorage();

    OrganisationInterface(newOrgAddress).setDataStore(tokenLedger, eternalStorage);

    organisation.kill(newOrgAddress);

    organisations[key_] = newOrgAddress;
    OrganisationUpgraded(newOrgAddress, now);
  }
}

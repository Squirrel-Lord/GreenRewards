/* 
* Title: GreenClaim
*
* Author: Ross Baldwin
*
* Date: 7/23/2019
*
* Description: This smart contract defines a GreenClaim. A GreenClaim is issued by 
* someone who claims to have performed some environmentally-friendly act.
* Other accounts can verify that the GreenClaim is authentic. Anybody can
* view the details of a GreenClaim. Also, anyone can donate funds to a GreenClaim.
* Once the claimed reward threshold is met, the claimer can receive the donations
* which will also be disbursed equally among all verifiers. After donations are received,
* the GreenClaim is made inactive.
*
* NOTE: This version is designed in terms of Ether transfer. Transferring smaller values
* (i.e. Wei, Gwei, or Finney) could create unexpected results.
*/

pragma solidity ^0.5.1;

contract GreenClaim
{
    // Each GreenClaim has an associated ClaimType
    enum ClaimType { Recycle, Reuse, Repurpose, ResourceConservation, Compost, CO2Removal }
    
    ClaimType claimType;
    address payable claimer;
    address payable[] verifiers;
    uint numVerifiers;
    uint rewardThreshold;
    bool active;
    
    /* 
    * The constructor creates a GreenClaim with a specified ClaimType and rewardThreshold.
    *
    * Parameters: cType (IN) Describes what environmentally-friendly act was claimed
    *
    *             reward (IN) The threshold donation amount that must be met in order
    *               for the claimer to receive the donations
    */
    constructor (ClaimType cType, uint reward) public
    {
        claimType = cType;
        rewardThreshold = (reward * 1000000000000000000);
        claimer = msg.sender;
        numVerifiers = 0;
        active = true;
    }
    
    /* 
    * This modifier ensures that a GreenClaim is active
    */
    modifier IsActive ()
    {
        require (active == true, "This GreenClaim is inactive");
        _;
    }
    
    /*
    * This function lets a user view a GreenClaim's ClaimType, number of past
    * verifiers, and rewardThreshold.
    *
    * Returns: ClaimType associated with GreenClaim
    *          Number of past verifiers
    *          Reward Threshold
    */
    function ViewClaim () public view returns (ClaimType, uint, uint)
    {
        return (claimType, numVerifiers, (rewardThreshold / 1000000000000000000));
    }
    
    /*
    * This function lets a user view the current total donation amount of
    * a GreenClaim.
    *
    * Returns: Current amount (in ETH) donated to GreenClaim
    */
    function ViewDonations () public view returns (uint)
    {
        return address(this).balance;
    }
    
    /*
    * This function allows a user to verify the a GreenClaim is authentic.
    */
    function VerifyClaim () public
    {
        verifiers.push(msg.sender);
        numVerifiers++;
    }
    
    /*
    * This function gets donations from users and stores them in the GreenClaim.
    * The GreenClaim must be active for a user to donate funds.
    */
    function Donate () payable public IsActive
    {
        
    }
    
    /*
    * This function allows the claimer to receive donations. Only the
    * claimer can call this function. The GreenClaim must be active and
    * its reward threshold must be met for the claimer to receive donations.
    * The donation amount is evenly distributed among all verifiers
    * and the claimer.
    */
    function ReceiveDonation () public payable IsActive
    {
        require (msg.sender == claimer);
        require (address(this).balance >= rewardThreshold);
        uint portion = (rewardThreshold / (numVerifiers + 1));
        for (uint i = 0; i < numVerifiers; i++)
            verifiers[i].transfer(portion);
        msg.sender.transfer(address(this).balance);
        active = false;
    }

}
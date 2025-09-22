pragma solidity ^0.6.7;
pragma experimental ABIEncoderV2;

import './IReasoningContract.sol';

contract EmploymentContract {

    bool employeeIsNoLongerNeeded = false;
    bool employeeIsPregnant = false;
    address employeeAddress;
    address employerAddress;
    address reasonerAddress;

    event ReasoningEvent(bool result);

    constructor(address _employeeAddress, address _reasonerAddress) public  {
        employerAddress = msg.sender;
        employeeAddress = _employeeAddress;
        reasonerAddress = _reasonerAddress;
    }

    function setEmployeeIsPregnant(bool value) public {
        //require(msg.sender == employee, "Only employee can call this function.");
        employeeIsPregnant = value;
    }
    function setEmployeeIsNoLongerNeeded(bool value) public {
        //require(msg.sender == employer, "Only employer can call this function.");
        employeeIsNoLongerNeeded = value;
    }
    function isEmploymentTerminated() external returns (bool) {
        uint factsCount = (employeeIsNoLongerNeeded?1:0) + (employeeIsPregnant?1:0);
        IReasoningContract reasoner = IReasoningContract(reasonerAddress);
        IReasoningContract.ReasoningTerm[] memory data = new IReasoningContract.ReasoningTerm[](factsCount);

        uint index = 0;
        if (employeeIsPregnant)
            data[index++] = reasoner.newTerm("pregnant","employee");
        if (employeeIsNoLongerNeeded)
            data[index++] = reasoner.newTerm("noLongerNeeded","employee");
        
        IReasoningContract.ReasoningTerm memory query = reasoner.newTerm("employmentTerminated","employee");
        bool result = reasoner.concludeDefeasibly(data, query);
        // bool result = reasoner.concludeDefinitely(data, query);
        emit ReasoningEvent(result);
        return result;
    }
}

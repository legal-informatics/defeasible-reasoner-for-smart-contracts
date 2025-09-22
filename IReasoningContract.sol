pragma solidity ^0.6.7;
pragma experimental ABIEncoderV2;

interface IReasoningContract {

	struct ReasoningTerm {
    	string name;
    	string[] arguments;
	}

	function concludeDefeasibly(ReasoningTerm[] calldata data, ReasoningTerm calldata query) external returns (bool);
    function concludeDefinitely(ReasoningTerm[] calldata data, ReasoningTerm calldata query) external returns (bool);
	function newTerm(string calldata _name, string calldata _argument0) external  pure returns (ReasoningTerm memory);
	function newTerm(string calldata _name, string calldata _argument0, string calldata _argument1) external pure returns (ReasoningTerm memory);
	function newTerm(string calldata _name, string calldata _argument0, string calldata _argument1, string calldata _argument2) external pure returns (ReasoningTerm memory);
	
}
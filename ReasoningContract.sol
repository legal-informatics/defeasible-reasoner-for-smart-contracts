// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.7;
pragma experimental ABIEncoderV2;

import './IReasoningContract.sol';
import 'prolog/Builder.sol';
import 'prolog/Prolog.sol';
import 'prolog/Substitution.sol';

contract ReasoningContract is TermBuilder, IReasoningContract {
	using RuleBuilder for Rule[];
	using Substitution for Substitution.Info;

	Substitution.Info substitutions;
	Rule[] rule_base;

	constructor() public {

		loadLegalRules();

		loadMetaProgram();
	}
	function concludeDefeasibly(ReasoningTerm[] memory data, ReasoningTerm memory query) public override returns (bool) {
		return conclude("defeasibly", data, query);
	}
	function concludeDefinitely(ReasoningTerm[] memory data, ReasoningTerm memory query) public override returns (bool) {
		return conclude("definitely", data, query);
	}
	function conclude(string memory queryType, ReasoningTerm[] memory data, ReasoningTerm memory query) public returns (bool) {
		Rule[] memory inputData = new Rule[](data.length);
		for (uint i=0; i<data.length; i++) {
			if (data[i].arguments.length == 0) {
				fromMemory(inputData[i].head, pred("fact", atom(bytes(data[i].name))));
			} else if (data[i].arguments.length == 1) {
				fromMemory(inputData[i].head, pred("fact", pred(bytes(data[i].name), atom(bytes(data[i].arguments[0])) )));
			} else if (data[i].arguments.length == 2) {
				fromMemory(inputData[i].head, pred("fact", pred(bytes(data[i].name), atom(bytes(data[i].arguments[0])), atom(bytes(data[i].arguments[1])) )));
			}
		}
		Term memory _term = pred(bytes(queryType), pred(bytes(query.name),atom(bytes(query.arguments[0]))));

        bool success = Prolog.query(
			_term,
			inputData,
			rule_base,
			substitutions
		);
		substitutions.clear();
		return success;
	}


	function loadLegalRules() internal {

/* RULEBASE_PLACEHOLDER */

	}

	function loadMetaProgram() internal {
		rule_base.add(pred("supportive_rule", Var("Name"), Var("Head"), Var("Body")),
						pred("strict", Var("Name"), Var("Head"), Var("Body")));
		rule_base.add(pred("supportive_rule", Var("Name"), Var("Head"), Var("Body")),
						pred("defeasible", Var("Name"), Var("Head"), Var("Body")));
		rule_base.add(pred("rule", Var("Name"), Var("Head"), Var("Body")),
						pred("supportive_rule", Var("Name"), Var("Head"), Var("Body")));
		
		rule_base.add(pred("definitely", Var("X")), pred("fact", Var("X")));
		rule_base.add(pred("definitely", Var("X")),
						pred("strict", ignore(), Var("X"), Var("L")),
						pred("definitely_provable", Var("L")));

		rule_base.add(pred("definitely_provable", list()));
		rule_base.add(pred("definitely_provable", Var("X")), pred("definitely", Var("X")));
		rule_base.add(pred("definitely_provable", listHT(Var("X1"), Var("X2"))),
						pred("definitely_provable", Var("X1")),
						pred("definitely_provable", Var("X2")));

		rule_base.add(pred("defeasibly", Var("X")), pred("definitely", Var("X")));
		rule_base.add(pred("defeasibly", Var("X")),
						pred("supportive_rule", Var("R"), Var("X"), Var("L")),
						pred("defeasibly_provable", Var("L")),
						pred("negation", Var("X"), Var("X1")),
						predNot("definitely", Var("X1")),
						predNot("overruled", Var("R"), Var("X")));

		rule_base.add(pred("defeasibly_provable", list()));
		rule_base.add(pred("defeasibly_provable", Var("X")), pred("defeasibly", Var("X")));
		rule_base.add(pred("defeasibly_provable", listHT(Var("X1"), Var("X2"))),
						pred("defeasibly_provable", Var("X1")),
						pred("defeasibly_provable", Var("X2")));

		rule_base.add(pred("defeated", Var("S"), Var("X")),
						pred("sup", Var("T"), Var("S")),
						pred("negation", Var("X"), Var("X1")),
						pred("supportive_rule", Var("T"), Var("X1"), Var("V")),
						pred("defeasibly_provable", Var("V")));

		rule_base.add(pred("overruled", ignore(), Var("X")),
						pred("negation", Var("X"), Var("X1")),
						pred("supportive_rule", Var("S"), Var("X1"), Var("U")),
						pred("supported_list", Var("U")),
						predNot("defeated", Var("S"), Var("X1"))); 

		rule_base.add(pred("supported", Var("X")), pred("definitely", Var("X")));
		rule_base.add(pred("supported", Var("X")),
						pred("supportive_rule", Var("R"), Var("X"), Var("L")),
						pred("supported_list", Var("L")),
						predNot("defeated", Var("R"), Var("X")));

		rule_base.add(pred("supported_list", list()));
		rule_base.add(pred("supported_list", Var("X")), pred("supported", Var("X")));
		rule_base.add(pred("supported_list", listHT(Var("X1"), Var("X2"))),
						pred("supported_list", Var("X1")),
						pred("supported_list", Var("X2")));
	}

	function newTerm(string memory _name, string memory _argument0) public pure override  returns (ReasoningTerm memory) {
		string[] memory args = new string[](1);
		args[0] = _argument0;
		return ReasoningTerm(_name, args);
    }

    function newTerm(string memory _name, string memory _argument0, string memory _argument1) public pure override  returns (ReasoningTerm memory) {
		string[] memory args = new string[](2);
		args[0] = _argument0;
		args[1] = _argument1;
		return ReasoningTerm(_name, args);
    }
    
    function newTerm(string memory _name, string memory _argument0, string memory _argument1, string memory _argument2) public pure override  returns (ReasoningTerm memory) {
		string[] memory args = new string[](3);
		args[0] = _argument0;
		args[1] = _argument1;
		args[2] = _argument2;
		return ReasoningTerm(_name, args);
	}

	function fromMemory(Term memory _to, Term memory _from) internal {
		_to.kind = _from.kind;
		_to.symbol = _from.symbol;
		delete _to.arguments;
		_to.arguments = new Term[](_from.arguments.length);
		for (uint i = 0; i < _from.arguments.length; ++i)
			fromMemory(_to.arguments[i], _from.arguments[i]);
	}

	function fromMemory(Rule memory o_to, Rule memory _from) internal {
		fromMemory(o_to.head, _from.head);

		for (uint i = 0; i < _from.body.length; ++i)
			fromMemory(o_to.body[i], _from.body[i]);
	}
}


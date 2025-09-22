Defeasible Reasoner for Smart Contracts
=======================================
This repository contains an implementation of defeasible reasoner for smart contracts written in the Solidity programming language. The reasoner is built on top of the `[SolPrologV2 Prolog interpreter] <https://github.com/leonardoalt/SolPrologV2>`_, resulting in an extended version that supports defeasible logic. The source files reflecting the modifications made to the original implementation are located in the ``prolog`` directory.

The capabilities of the reasoner (``ReasoningContract.sol``) are demonstrated using a sample employment contract (``EmploymentContract.sol``) for the automatic determination of employment termination in accordance with a legal framework i.e. legal rules defined in the LegalRuleML format (``rulebase.xml``). Additionally, a utility tool is implemented in Python to facilitate the construction of smart contract for defeasible reasoning. The usage of the tool is explained using the following command:

.. code::

    python util.py --help


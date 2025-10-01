from solcx import compile_standard, compile_files, install_solc
import json
import lxml.etree as ET
from web3 import Web3
import argparse

_solc_version = "0.6.7"
install_solc(_solc_version)

endpointURI = "http://127.0.0.1:8545"
w3 = Web3(Web3.HTTPProvider(endpointURI))
# chain_id = 31337
address = "0x_my_address"
private_key = "0x_my_private_key"
employee_addr = "0x_employee_address"

def buildReasoningContract(lrmlFile, template, outputFile):
    dom = ET.parse(lrmlFile)
    xslt = ET.parse("./lrml2pred.xslt")
    transform = ET.XSLT(xslt)
    rulebase = str(transform(dom))
    with open(template, "r") as file:
        solidityCode = file.read()
    solidityCode = solidityCode.replace("/* RULEBASE_PLACEHOLDER */",rulebase)
    with open(outputFile, "w") as file:
        file.write(solidityCode)
    
def compileReasoningContract():
    dom = ET.parse("./rulebase.xml")
    xslt = ET.parse("./lrml2pred.xslt")
    transform = ET.XSLT(xslt)
    rulebase = str(transform(dom))
    
    with open("ReasoningContract.sol", "r") as file:
        solidityCode = file.read()
    solidityCode = solidityCode.replace("/* RULEBASE_PLACEHOLDER */",rulebase)
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {"ReasoningContract.sol": {"content": solidityCode}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    }, solc_version=_solc_version, allow_paths="." )
    abi = json.loads(compiled_sol["contracts"]["ReasoningContract.sol"]["ReasoningContract"]["metadata"])["output"]["abi"]
    bytecode = compiled_sol["contracts"]["ReasoningContract.sol"]["ReasoningContract"]["evm"]["bytecode"]["object"]
    return abi, bytecode


def compileEmplymentContract():
    compiled_sol = compile_files(
        ["EmploymentContract.sol"],
        output_values=["abi", "bin"],
        solc_version="0.6.7"
    )
    abi = compiled_sol["EmploymentContract.sol:EmploymentContract"]["abi"]
    bytecode = compiled_sol["EmploymentContract.sol:EmploymentContract"]["bin"]
    return abi, bytecode
     

def function_call(fn):
    nonce = w3.eth.get_transaction_count(address)
    transaction = fn.build_transaction({"from": address, "nonce": nonce})
    sign_transaction = w3.eth.account.sign_transaction(transaction, private_key=private_key)
    transaction_hash = w3.eth.send_raw_transaction(sign_transaction.raw_transaction)
    transaction_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash)
    return transaction_receipt
    
def compileAndDeploy(solidityFile, endpoint, addr, key):
    with open(solidityFile, "r") as file:
        solidityCode = file.read()
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {"ReasoningContract.sol": {"content": solidityCode}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    }, solc_version=_solc_version, allow_paths="." )
    abi = json.loads(compiled_sol["contracts"]["ReasoningContract.sol"]["ReasoningContract"]["metadata"])["output"]["abi"]
    bytecode = compiled_sol["contracts"]["ReasoningContract.sol"]["ReasoningContract"]["evm"]["bytecode"]["object"]

    w3 = Web3(Web3.HTTPProvider(endpoint))
    ReasoningContract = w3.eth.contract(abi=abi, bytecode=bytecode)
    
    nonce = w3.eth.get_transaction_count(addr)
    transaction = ReasoningContract.constructor().build_transaction({"from": addr, "nonce": nonce})
    sign_transaction = w3.eth.account.sign_transaction(transaction, private_key=key)
    transaction_hash = w3.eth.send_raw_transaction(sign_transaction.raw_transaction)
    transaction_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash)
    return transaction_receipt

def demo():
    ReasoningContract_abi, ReasoningContract_bytecode = compileReasoningContract()
    EmploymentContract_abi, EmploymentContract_bytecode = compileEmplymentContract()

    ReasoningContract = w3.eth.contract(abi=ReasoningContract_abi, bytecode=ReasoningContract_bytecode)
    transaction_receipt = function_call(ReasoningContract.constructor())
    print(f"ReasoningContract deployed to {transaction_receipt.contractAddress}",", gas used=",transaction_receipt.gasUsed)

    EmploymentContract = w3.eth.contract(abi=EmploymentContract_abi, bytecode=EmploymentContract_bytecode)
    transaction_receipt = function_call(EmploymentContract.constructor(
        employee_addr,
        transaction_receipt.contractAddress
    ))
    print(f"EmploymentContract deployed to {transaction_receipt.contractAddress}",", gas used=",transaction_receipt.gasUsed)

    employmentContract = w3.eth.contract(address=transaction_receipt.contractAddress, abi=EmploymentContract_abi)
    function_call(employmentContract.functions.setEmployeeIsNoLongerNeeded(False))
    function_call(employmentContract.functions.setEmployeeIsPregnant(False))
    print("False","False",employmentContract.functions.isEmploymentTerminated().call())

    function_call(employmentContract.functions.setEmployeeIsNoLongerNeeded(False))
    function_call(employmentContract.functions.setEmployeeIsPregnant(True))
    print("False","True(pregnant)",employmentContract.functions.isEmploymentTerminated().call())

    function_call(employmentContract.functions.setEmployeeIsNoLongerNeeded(True))
    function_call(employmentContract.functions.setEmployeeIsPregnant(False))
    print("True(notneeded)","False",employmentContract.functions.isEmploymentTerminated().call())

    function_call(employmentContract.functions.setEmployeeIsNoLongerNeeded(True))
    function_call(employmentContract.functions.setEmployeeIsPregnant(True))
    print("True","True",employmentContract.functions.isEmploymentTerminated().call())

    # function_call(employmentContract.functions.setEmployeeIsPregnant(False))
    # print(employmentContract.functions.isEmploymentTerminated().call())

    function_call(employmentContract.functions.setEmployeeIsNoLongerNeeded(True))
    function_call(employmentContract.functions.setEmployeeIsPregnant(False))

    transaction_receipt = function_call(employmentContract.functions.isEmploymentTerminated())
    print(f"transaction executed",", gas used=",transaction_receipt.gasUsed)
    event = employmentContract.events.ReasoningEvent().process_receipt(transaction_receipt)
    print(event)
    print(event[0]['args'])

    print("True(notneeded)","False",employmentContract.functions.isEmploymentTerminated().call())


parser = argparse.ArgumentParser(description="Utility tool for building reasoning contracts.")
parser.add_argument("-r", "--rules", help="LegalRulML file")
parser.add_argument("-t", "--template", help="Solidity template file")
parser.add_argument("-o", "--output", help="Otput Solidity file")
parser.add_argument("-c", "--compile", action='store_true', help="Compile the reasoning contract")
parser.add_argument("-d", "--deploy", action='store_true', help="Deploy the reasoning contract")
parser.add_argument("-dm", "--demo", action='store_true', help="Demo of building, compiling, deploying, testing the reasoning contract.")
args = parser.parse_args()

if args.rules and args.template and args.output:
    buildReasoningContract(args.rules, args.template, args.output)
    if args.compile and args.deploy:
        endpoint = input("Enter the endpoint URI: ") or endpointURI
        addr = input("Enter your address: ") or address
        key = input("Enter your key: ") or private_key
        transaction_receipt = compileAndDeploy(args.output, endpoint, addr, key)
        print(f"ReasoningContract deployed to {transaction_receipt.contractAddress}",", gas used=",transaction_receipt.gasUsed)
else:
    demo()


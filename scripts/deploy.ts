// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import * as fs from 'fs';
import * as path from 'path';
import {ethers} from 'ethers'
import {writeFileSync} from "fs";


const hre = require('hardhat')


async function main() {
    //==================== todo The constructor is the value that needs to be passed in when the contract is deployed ====================
    let FactoryABI = ["function initialize(uint64,address,uint256)"];

    let ifaceFactory = new ethers.utils.Interface(FactoryABI);
    let getABI = ifaceFactory.encodeFunctionData("initialize",["1000000000000000000","0x46D37d38101BCf69C1ca4073e997347e85f93033","20000000000000000000"]);
    console.info(`getABI:` + getABI);

/*    //==================== todo Deploy TestERC20 contract ====================
    const TestERC20 = await hre.ethers.getContractFactory("TestERC20");
    //Number,name,symbol of constructors passed in
    const testERC20 = await TestERC20.deploy("TEST", "TS", "100000000000000000000000000000000000000000000000000000000");
    await testERC20.deployed();
    console.log("TestERC20 deployed to:", testERC20.address);

    //==================== todo Deploy MerkleDistributorFactory Contract ====================
    const MerkleDistributorFactory = await hre.ethers.getContractFactory("MerkleDistributorFactory");
    //No constructor
    const merkleDistributorFactory = await MerkleDistributorFactory.deploy();
    await merkleDistributorFactory.deployed();
    console.log("MerkleDistributorFactory deployed to:", merkleDistributorFactory.address);

    //==================== todo Deploy ContractProxy Contract ====================
    const ContractProxy = await hre.ethers.getContractFactory("ContractProxy");
    //No constructor
    const contractProxy = await ContractProxy.deploy();
    await contractProxy.deployed();
    console.log("contractProxy deployed to:", contractProxy.address);

    //==================== todo Deploy TransparentUpgradeableProxy Contract ====================
    const TransparentUpgradeableProxy = await hre.ethers.getContractFactory("TransparentUpgradeableProxy");
    //No constructor
    const transparentUpgradeableProxy = await TransparentUpgradeableProxy.deploy(merkleDistributorFactory.address, contractProxy.address, getABI);
    await transparentUpgradeableProxy.deployed();
    console.log("transparentUpgradeableProxy deployed to:", transparentUpgradeableProxy.address);


    let Global1 = "{\n" +
        "  \"TestERC20\": \""+ testERC20.address +"\",\n" +
        "  \"proxyAdmin\": \""+ contractProxy.address +"\",\n" +
        "  \"MerkleDistributorFactory\": \""+ transparentUpgradeableProxy.address +"\"\n" +
        "}";
    addjson(Global1, "./other/contractAddr.json");*/
}

//生成持久化json文件
function addjson(data, address) {
    writeFileSync(address, data);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import * as fs from 'fs';
import * as path from 'path';

const hre = require('hardhat')

import {BigNumber, ethers} from 'ethers'
import {ArgumentParser} from 'argparse';

const MerkleDistributorFactoryAbi = require('../artifacts/contracts/MerkleDistributorFactory.sol/MerkleDistributorFactory.json');
const TestERC20 = require('../artifacts/contracts/test/TestERC20.sol/TestERC20.json');
const contractAddr = require('../other/contractAddr.json');
const global = require('../other/global.json');


async function main() {

    /*
    const parser = new ArgumentParser({
            add_help: true,
             description: 'call claim transaction'
         });

         parser.add_argument('--userPrk', {required: true, help: 'user prite key'});
         parser.add_argument('--tokenAddress', {required: true, help: 'pay token address'});
         parser.add_argument('--contractAddress', {
             required: true,
             help: 'NFT Factory Contract address'
         });
     const args = parser.parse_args(process.argv.slice(2));
     let contractProxy = args.contractAddress;
     let privateKey = args.userPrk;
     console.log(privateKey);*/

    let merkleDistributorFactory = wallets(contractAddr.MerkleDistributorFactory, MerkleDistributorFactoryAbi.abi);
    //==================== todo Set admin rights ====================

    let financial = await merkleDistributorFactory.FINANCIAL_ADMINISTRATOR();
    //console.log("financial bytes:" + financial);

    let grantRole_financial = await merkleDistributorFactory.grantRole(financial, global.loaclhost.user_address);
    console.log("grantRole_financial hash:" + grantRole_financial.hash);
    await grantRole_financial.wait();
    console.log("grantRole_financial finish");

    let project = await merkleDistributorFactory.PROJECT_ADMINISTRATORS();
    //console.log("project bytes:" + project);

    let grantRole_project = await merkleDistributorFactory.grantRole(project, global.loaclhost.user_address);
    console.log("grantRole_project hash:" + grantRole_project.hash);
    await grantRole_project.wait();
    console.log("grantRole_project finish");

}


function wallets(addr, abi) {
    let provider = ethers.getDefaultProvider(global.loaclhost.work);
    let privateKey = global.loaclhost.private_key;
    let contract = new ethers.Contract(addr, abi, provider);
    // 从私钥获取一个签名器 Signer
    let wallet = new ethers.Wallet(privateKey, provider);
    // 使用签名器创建一个新的合约实例，它允许使用可更新状态的方法
    return contract.connect(wallet);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
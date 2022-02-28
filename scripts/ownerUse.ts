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

const MetaDexSwapFactoryAbi = require('../artifacts/contracts/MetaDexSwap.sol/MetaDexSwap.json');
const ProxyAdmin = require('../artifacts/contracts/utils/ContractPorxy.sol/ContractProxy.json');
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

    let proxyAdmin = wallets(contractAddr.proxyAdmin, ProxyAdmin.abi);

    let metaDexSwapProxy = wallets(contractAddr.MetaDexSwapProxy, MetaDexSwapFactoryAbi.abi);

    //==================== todo Set admin rights ====================

    const MetaDexSwap = await hre.ethers.getContractFactory("MetaDexSwap");
    const metaDexSwap = await MetaDexSwap.deploy();
    await metaDexSwap.deployed();
    console.log("metaDexSwap deployed to:", metaDexSwap.address);

    const upgrade = await proxyAdmin.upgrade(contractAddr.MetaDexSwapProxy, metaDexSwap.address);
    console.log("Upgrade哈希:" + upgrade.hash);
    await upgrade.wait();
    console.log("Upgrade完成");
}


function wallets(addr, abi) {
    let provider = ethers.getDefaultProvider(contractAddr.testNetwork);
    let privateKey = contractAddr.localUserKey;
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
# Connect an æpp to a wallet

## Introduction

This guide describes the 3 steps that are necessary to connect your application to a wallet using the RPC API.

Note:

- The steps below are snippets taken from the full implementation of the [Simple æpp](https://github.com/aeternity/aepp-sdk-js/tree/master/examples/browser/aepp)

## 1. Initialize the `RpcAepp` Stamp

```js
import { RpcAepp, WalletDetector, BrowserWindowMessageConnection } from '@aeternity/aepp-sdk'

async created () {
  this.aeSdk = await RpcAepp({
    name: 'Simple Aepp',
    nodes: [
      { name: 'ae_uat', instance: await Node({ url: TEST_NET_NODE_URL }) },
      { name: 'ae_mainnet', instance: await Node({ url: MAIN_NET_NODE_INTERNAL_URL }) }
    ],
    compilerUrl: COMPILER_URL,
    onNetworkChange: async (params) => {
      this.aeSdk.selectNode(params.networkId)
      this.nodeInfoResponse = await this.aeSdk.getNodeInfo()
    },
    onAddressChange:  async (addresses) => {
      this.pub = await this.aeSdk.address()
      this.balance = await this.aeSdk.balance(this.pub).catch(e => '0')
      this.addressResponse = await this.aeSdk.address()
    },
    onDisconnect: () => {
      this.resetState()
      alert('Disconnected')
    }
  })
  this.height = await this.aeSdk.height()
  // start looking for wallets, see step 2.
  this.scanForWallets()
  // open iframe with Wallet if run in top window
  if (window === window.parent) this.openReverseIframe()
}
```

## 2. Scan for wallets
```js
scanForWallets () {
  const handleWallets = async function ({ wallets, newWallet }) {
    newWallet = newWallet || Object.values(wallets)[0]
    if (confirm(`Do you want to connect to wallet ${newWallet.name}`)) {
      this.detector.stopScan()
      // connect to the wallet, see step 3.
      await this.connectToWallet(newWallet)
    }
  }

  const scannerConnection = BrowserWindowMessageConnection({
    connectionInfo: { id: 'spy' }
  })
  this.detector = WalletDetector({ connection: scannerConnection })
  this.detector.scan(handleWallets.bind(this))
}
```

## 3. Connect to Wallet

```js
async connectToWallet (wallet) {
  await this.aeSdk.connectToWallet(await wallet.getConnection())
  this.accounts = await this.aeSdk.subscribeAddress('subscribe', 'connected')
  this.pub = await this.aeSdk.address()
  this.onAccount = this.pub
  this.balance = await this.aeSdk.getBalance(this.pub)
  this.walletName = this.aeSdk.rpcClient.info.name
  this.addressResponse = await this.aeSdk.address()
  this.heightResponse = await this.aeSdk.height()
  this.nodeInfoResponse = await this.aeSdk.getNodeInfo()
}
```

## 4. Use Wallet's Node for chain communication

AEPP can request the wallet to share its connected node URLs if any to interact with the chain.

```js
async connectToWallet (wallet) {
    await this.aeSdk.connectToWallet(await wallet.getConnection(), { connectNode: true, name: 'wallet-node', select: true })
}
```

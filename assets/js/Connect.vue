<template>
<div class="row mt-3">
  <div class="row mt-6">
    <div class="col-sm-3"> Wallet url</div>
    <div class="col-sm-6"><a target="_blank" :href="this.walletUrl">{{ this.walletUrl }}</a></div>
  </div>
  <div class="row mt-6">
    <div class="col-sm-3"> Faucet url</div>
    <div class="col-sm-6"><a target="_blank" :href="this.faucetUrl">{{ this.faucetUrl }}</a></div>
  </div>

  <div class="row mt-6" v-if="walletConnected">
    <div class="col-sm-3"> Wallet name</div>
    <div class="col-sm-6">{{ walletName }}</div>
  </div>

  <div class="row mt-6" v-if="walletConnected">
    <div class="col-sm-3"> Wallet network id</div>
    <div class="col-sm-6">{{ walletNetworkId }}</div>
  </div>

  <div class="row mt-6" v-if="walletConnected">
    <div class="col-sm-3">Wallet Address</div>
    <div class="col-sm-6"><b>{{ this.walletAddress }}</b></div>
  </div>

  <div class="row mt-6" v-if="walletConnected">
    <div class="col-sm-3">Address Balance</div>
    <div class="col-sm-6"><b>{{ aeBalance }}</b> AE</div>
  </div>

  <div class="row mt-6" v-if="walletConnected">
    <div class="col-sm-3">Node Height</div>
    <div class="col-sm-6">{{ this.nodeHeight }}</div>
  </div>

  <div class="row mt-3">
    <div class="col-sm-3">
    <a class="btn btn-dark mt-3" v-if="!walletConnected" @click="connectPromise = connect().then(() => 'Ready')" > Connect </a>
    <a class="btn btn-dark mt-3" v-if="walletConnected" @click="disconnect" > Disconnect </a>
    </div>
  </div>
</div>

</template>

<script>
import { RpcAepp, Node, WalletDetector, BrowserWindowMessageConnection } from '@aeternity/aepp-sdk'
import { AmountFormatter } from '@aeternity/aepp-sdk'

const COMPILER_URL = 'https://compiler.aepps.com'

export default {
  emits: {
    aeSdk: Object,
    address: String,
    networkId: String,
  },
  props: {
    nodeUrl: { type: String, default: '' },
    faucetUrl: { type: String, default: '' },
    walletUrl: { type: String, default: '' }
  },
  data: () => ({
    aeSdk: null,
    walletConnected: false,
    connectPromise: null,
    reverseIframe: null,
    walletAddress: '',
    nodeBalance: null,
    nodeHeight: null
  }),
  computed: {
    walletName () {
      if (!this.aeSdk) return 'SDK is not ready'
      if (!this.walletConnected) return 'Wallet is not connected'
      return this.aeSdk.rpcClient.info.name
    },
    walletNetworkId () {
      if (!this.aeSdk) return 'SDK is not ready'
      if (!this.walletConnected) return 'Wallet is not connected'
      return this.aeSdk.rpcClient.info.networkId
    },
    aeBalance() {
       return AmountFormatter.toAe(this.nodeBalance)
    }
  },
  methods: {
    async stats() {
      this.nodeBalance = await this.aeSdk.balance(this.walletAddress)
      this.nodeHeight = await this.aeSdk.height()
      setTimeout(() => { this.stats() }, 1000)
    },
    async scanForWallets () {
      const handleWallets = async function ({ wallets, newWallet }) {
        newWallet = newWallet || Object.values(wallets)[0]
        if (confirm(`Do you want to connect to wallet ${newWallet.name} with id ${newWallet.id}`)) {
          detector.stopScan()

          await this.aeSdk.connectToWallet(await newWallet.getConnection())
          this.walletConnected = true
          const { address: { current } } = await this.aeSdk.subscribeAddress('subscribe', 'connected')
          this.walletAddress = Object.keys(current)[0]
          this.$emit('address', this.walletAddress)

          this.stats()
        }
      }

      const scannerConnection = await BrowserWindowMessageConnection({
        connectionInfo: { id: 'spy' }
      })
      const detector = await WalletDetector({ connection: scannerConnection })
      detector.scan(handleWallets.bind(this))
    },
    async connect () {
      this.reverseIframe = document.createElement('iframe')
      this.reverseIframe.src = this.walletUrl
      this.reverseIframe.style.display = 'none'
      document.body.appendChild(this.reverseIframe)

      if (!this.aeSdk) {
        this.aeSdk = await RpcAepp({
          name: 'Simple æpp',
          nodes: [
            { name: 'hc', instance: await Node({ url: this.nodeUrl, ignoreVersion: true }) }
          ],
          compilerUrl: COMPILER_URL,
          onNetworkChange: ({ networkId }) => {
            const [{ name }] = this.aeSdk.getNodesInPool()
              .filter(node => node.nodeNetworkId === networkId)
            this.aeSdk.selectNode(name)
            this.$emit('networkId', networkId)
          },
          onAddressChange: ({ current }) => this.$emit('address', Object.keys(current)[0]),
          onDisconnect: () => alert('Aepp is disconnected')
        })
      }
      this.$emit('aeSdk', this.aeSdk)

      await this.scanForWallets()
    },
    async disconnect () {
      await this.aeSdk.disconnectWallet()
      this.walletConnected = false
      if (this.reverseIframe) this.reverseIframe.remove()
      this.$emit('aeSdk', null)
      this.$emit('address', '')
    }
  }
}
</script>

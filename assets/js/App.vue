<template>
<Connect
  @aeSdk="aeSdk = $event"
  @address="address = $event"
  @networkId="networkId = $event"
  :nodeUrl="nodeUrl"
/>

<Component
  v-if="address"
  :is="view"
  :aeSdk="aeSdk"
  :address="address"
  :networkId="networkId"
/>
</template>

<script>

import Connect from './Connect.vue'
import Staking from './Staking.vue'

export default {
  components: { Connect, Staking },
  data: () => ({
    view: "Staking",
    aeSdk: null,
    address: '',
    networkId: '',
    nodeUrl: ''
  }),
  mounted () {
    this.nodeUrl = document.getElementById('nodeUrl').value
  }
}
</script>

<template>
  <div class="row mt-6">
    <div class="col-sm-6">
      <br /><h4>stake</h4>
  <div class="group">
    <div class="row g-3 mt-6">
      <div class="col-sm-4">Validator address</div>
      <div class="col-sm-8"><input class="form-control" v-model="stakeValidator" placeholder="ak_..." ></div>
    </div>
    <div class="row mt-6">
      <div class="col-sm-4">Amount in AE</div>
      <div class="col-sm-8"><input class="form-control" v-model="stakeAmount" placeholder="0.0"></div>
    </div>
    <br />
    <a v-if="contract" class="btn btn-dark" @click="stakePromise = stake()"> Stake </a>
    <br />
    <div v-if="stakePromise">
      <br />
      <div>Raw result:</div>
      <Value :value="stakePromise" />
    </div>
  </div>
    </div>
    <div class="col-sm-6">
      <br /><h4>unstake</h4>
  <div class="group">
    <div class="row g-3 mt-6">
      <div class="col-sm-4">Validator address</div>
      <div class="col-sm-8"><input class="form-control" v-model="unstakeValidator" placeholder="ak_..." ></div>
    </div>
    <div class="row mt-6">
      <div class="col-sm-4">Number of shares</div>
      <div class="col-sm-8"><input class="form-control" v-model="unstakeAmount" placeholder="0.0"></div>
    </div>
    <br />
    <a v-if="contract" class="btn btn-dark" @click="unstakePromise = unstake()"> Unstake </a>
    <br />
    <div v-if="unstakePromise">
      <br />
      <div>Raw result:</div>
      <Value :value="unstakePromise" />
    </div>
  </div>
    </div>
  </div>


</template>

<script>
import Value from './Value.vue'
import { AmountFormatter } from '@aeternity/aepp-sdk'

const contractSource = `
include "List.aes"
contract interface StakingValidator =
  record validator_state = { main_staking_ct : address, delegates : map(address, int), shares : int }
  entrypoint init : address => unit
  payable stateful entrypoint stake : address => unit
  payable entrypoint profit : () => unit
  stateful entrypoint unstake : (address, int) => int
  entrypoint get_state : () => validator_state

main contract MainStaking =
  datatype bucket = ONLINE | OFFLINE

  record validator =
    { ct : StakingValidator, stake : int }

  record state =
    { staking_validator_ct  : StakingValidator,
      online_validators     : map(address, validator),
      offline_validators    : map(address, validator),
      total_stake           : int,
      entropy               : hash,
      leader                : address
      }

  entrypoint init(staking_validator_ct : StakingValidator, entropy_str : string) =
    { staking_validator_ct  = staking_validator_ct,
      online_validators     = {},
      offline_validators    = {},
      total_stake           = 0,
      entropy               = Crypto.sha256(entropy_str),
      leader                = Contract.address
      }

  entrypoint online_validators() =
    let vs = Map.to_list(state.online_validators)
    [ (v, s) | (v, {stake = s}) <- vs ]

  entrypoint offline_validators() =
    let vs = Map.to_list(state.offline_validators)
    [ (v, s) | (v, {stake = s}) <- vs ]

  payable stateful entrypoint new_validator() : StakingValidator =
    require(Call.value >= 1_000_000_000_000_000_000_000, "Must stake the minimum amount")
    let validator_ct : StakingValidator = Chain.clone(ref = state.staking_validator_ct, Contract.address)
    validator_ct.stake(value = Call.value, Call.caller)
    put(state{offline_validators[Call.caller] = {ct = validator_ct, stake = Call.value}})
    validator_ct

  stateful entrypoint set_online() =
    require(validator_bucket(Call.caller) == OFFLINE, "Validator not offline")
    let validator = state.offline_validators[Call.caller]
    put(state{online_validators[Call.caller] = validator,
              offline_validators @ offv = Map.delete(Call.caller, offv),
              total_stake @ ts = ts + validator.stake})

  stateful entrypoint set_offline() =
    require(validator_bucket(Call.caller) == ONLINE, "Validator not online")
    let validator = state.online_validators[Call.caller]
    put(state{offline_validators[Call.caller] = validator,
              online_validators @ onv = Map.delete(Call.caller, onv),
              total_stake @ ts = ts - validator.stake})

  payable stateful entrypoint stake(to : address) =
    require(Call.value >= 10_000_000_000_000_000_000, "Must stake the minimum amount")
    switch(validator_bucket(to))
      ONLINE =>
        let validator = state.online_validators[to]
        validator.ct.stake(value = Call.value, Call.caller)
        put(state{online_validators[to] = validator{ stake @ s = s + Call.value },
                  total_stake @ ts = ts + Call.value})
      OFFLINE =>
        let validator = state.offline_validators[to]
        validator.ct.stake(value = Call.value, Call.caller)
        put(state{offline_validators[to] = validator{ stake @ s = s + Call.value }})

  stateful entrypoint unstake(from : address, stakes : int) : int =
    switch(validator_bucket(from))
      ONLINE =>
        let validator = state.online_validators[from]
        let payout = validator.ct.unstake(Call.caller, stakes)
        put(state{online_validators[from] = validator{ stake @ s = s - payout},
                  total_stake @ ts = ts - Call.value})
        payout
      OFFLINE =>
        let validator = state.offline_validators[from]
        let payout = validator.ct.unstake(Call.caller, stakes)
        put(state{offline_validators[from] = validator{ stake @ s = s - payout }})
        payout

  payable stateful entrypoint reward(to : address) =
    //assert_protocol_call()
    switch(validator_bucket(to))
      ONLINE =>
        let validator = state.online_validators[to]
        validator.ct.profit(value = Call.value)
        put(state{online_validators[to] = validator{ stake @ s = s + Call.value },
                  total_stake @ ts = ts + Call.value})
      OFFLINE =>
        let validator = state.offline_validators[to]
        validator.ct.profit(value = Call.value)
        put(state{offline_validators[to] = validator{ stake @ s = s + Call.value }})

  entrypoint get_validator_state(v : address) =
    switch(validator_bucket(v))
      ONLINE =>
        let validator = state.online_validators[v]
        validator.ct.get_state()
      OFFLINE =>
        let validator = state.offline_validators[v]
        validator.ct.get_state()

  entrypoint leader() =
    state.leader

  stateful entrypoint elect() =
    assert_protocol_call()
    let new_leader = elect_at_height(Chain.block_height)
    put(state{ leader = new_leader})

  entrypoint elect_next() =
    elect_at_height(Chain.block_height + 1)

  entrypoint elect_at_height(height : int) =
    let sorted = List.sort(validator_cmp, Map.to_list(state.online_validators))
    let shot = Bytes.to_int(state.entropy) * height mod state.total_stake
    switch(find_validator(sorted, shot))
      None => abort("NO CANDIDATE") // should not be possible
      Some(new_leader) => new_leader

  entrypoint balance(who : address) =
    let validator = get_validator(who)
    validator.stake

  function get_validator(who : address) =
    switch(validator_bucket(who))
      ONLINE => state.online_validators[who]
      OFFLINE => state.offline_validators[who]

  function find_validator(validators, shot) =
    switch(validators)
      []   => None
      (validator_addr, validator : validator)::t =>
        if(validator.stake > shot) Some(validator_addr)
        else find_validator(t, shot - validator.stake)

  function validator_cmp((x_addr : address, x : validator), (y_addr : address, y : validator)) =
    if (x.stake == y.stake) x_addr < y_addr else x.stake < y.stake

  function validator_bucket(who) : bucket =
    switch(Map.member(who, state.online_validators))
      true =>
        ONLINE
      false =>
        switch(Map.member(who, state.offline_validators))
          true =>
            OFFLINE
          false =>
            abort("Validator must exists")

  function assert_protocol_call() =
      require(Call.caller == Contract.creator, "Must be called by the protocol")
`.trim()

export default {
  components: { Value },
  props: {
    aeSdk: { type: Object, required: true },
    address: { type: String, default: '' },
    networkId: { type: String, default: '' },
  },
  data: () => ({
    contract: null,
    contractSource,
    stakeValidator:  '',
    stakeAmount: '',
    stakePromise: null,
    unstakeValidator:  '',
    unstakeAmount: '',
    unstakePromise: null
  }),
  async mounted () {
    tmp = await this.aeSdk.getContractInstance({ source: this.contractSource })
    this.contract = await this.aeSdk.getContractInstance({ aci: tmp._aci, contractAddress:"ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"}  )
  },
  methods: {
    async stake () {
      result = this.contract.methods.stake(this.stakeValidator, { amount: AmountFormatter.toAettos(this.stakeAmount) })
      this.stakeAmount = ''
      return result
    },
    async unstake () {
      result = this.contract.methods.unstake(this.unstakeValidator, BigInt(AmountFormatter.toAettos(this.unstakeAmount)) )
      this.unstakeAmount = ''
      return result
    }
  }
}
</script>

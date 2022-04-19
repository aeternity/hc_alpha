import {
  writeId, readId, isNameValid, produceNameId, ensureNameValid, getMinimumNameFee, readInt, writeInt
} from './helpers'
import { InsufficientNameFeeError, IllegalArgumentError } from '../../utils/errors'

export class Field {
  static serialize (value) {
    return value
  }

  static deserialize (value) {
    return value
  }
}

export class Name extends Field {
  static serialize (value) {
    ensureNameValid(value)
    return Buffer.from(value)
  }

  static deserialize (value) {
    return value.toString()
  }
}

export class NameId extends Field {
  static serialize (value) {
    return writeId(isNameValid(value) ? produceNameId(value) : value)
  }

  static deserialize (value) {
    return readId(value)
  }
}

export class NameFee extends Field {
  static serialize (value, { name }) {
    const minNameFee = getMinimumNameFee(name)
    value ??= minNameFee
    if (minNameFee.gt(value)) {
      throw new InsufficientNameFeeError(value, minNameFee)
    }
    return writeInt(value)
  }

  static deserialize (value) {
    return readInt(value)
  }
}

export class Deposit extends Field {
  static serialize (value, { name }) {
    if (+value) throw new IllegalArgumentError(`Contract deposit is not refundable, so it should be equal 0, got ${value} instead`)
    return writeInt(0)
  }

  static deserialize (value) {
    return readInt(value)
  }
}

import { getAccountAddress, mintFlow } from 'flow-js-testing'
import { ActorContext } from './actor'
import { ScriptResult } from './script'

const checkScriptSucceeded = <T>(result: ScriptResult<T>): ScriptResult<T> => {
  expect(result._tag).toBe('success')
  return result
}

const checkScriptFailed = <T>(result: ScriptResult<T>): ScriptResult<T> => {
  expect(result._tag).toBe('failure')
  return result
}

const checkScriptValue =
  <T>(expected: T) =>
  (result: ScriptResult<T>): ScriptResult<T> => {
    checkScriptSucceeded(result)
    result._tag === 'success' && expect(result.value).toStrictEqual(expected)
    return result
  }

const assertScriptValue =
  <T>(test: (value: T) => boolean) =>
  (result: ScriptResult<T>): ScriptResult<T> => {
    checkScriptSucceeded(result)
    result._tag === 'success' && expect(test(result.value)).toBeTruthy()
    return result
  }

const log = <T>(result: ScriptResult<T>): ScriptResult<T> => {
  console.log(result)
  return result
}

// =============================================================================

const checkSuccessfulTransactions =
  (num: number) => (context: ActorContext) => {
    expect(context.numSuccessfulTransactions).toBe(num)
    return context
  }

const checkContextAlive = (context: ActorContext) => {
  expect(context._tag).toBe('alive')
  return context
}

const checkContextDead = (context: ActorContext) => {
  expect(context._tag).toBe('dead')
  return context
}

const checkSkippedTransactions = (num: number) => (context: ActorContext) => {
  expect(context._tag).toBe('dead')
  context._tag == 'dead' && expect(context.numFailedTransactions).toBe(num)
  return context
}

const initAccount = async (name: string, flow: string): Promise<any> => {
  return getAccountAddress(name).then((account) => {
    mintFlow(account, flow)
  })
}

export {
  checkContextAlive,
  checkContextDead,
  checkSkippedTransactions,
  checkSuccessfulTransactions,
  checkScriptFailed,
  checkScriptValue,
  assertScriptValue,
  log,
  checkScriptSucceeded,
  initAccount,
}

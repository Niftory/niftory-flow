import { executeScript } from 'flow-js-testing'

type ScriptRequest<T> = {
  codePath: string
  args?: any[]
  decoder: (rawData: any) => T
}

type ScriptSuccess<T> = {
  _tag: 'success'
  value: T
}

type ScriptFailure = {
  _tag: 'failure'
  error: any
}

type ScriptResult<T> = ScriptSuccess<T> | ScriptFailure

const parseRawScriptResult =
  <T>(decoder: (rawData: any) => T) =>
  (result: any[]): ScriptResult<T> => {
    if (result.length != 2) {
      return {
        _tag: 'failure',
        error: new Error(`Unexpected raw script result: ${result}`),
      }
    }

    if (result[1] != null) {
      return {
        _tag: 'failure',
        error: result[1],
      }
    }

    // Return success if result[0] is truthy
    try {
      return {
        _tag: 'success',
        value: decoder(result[0]),
      }
    } catch (error) {
      return {
        _tag: 'failure',
        error,
      }
    }
  }

const execute = <T>(request: ScriptRequest<T>): Promise<ScriptResult<T>> =>
  (executeScript(request.codePath, request.args) as Promise<any[]>)
    .then(log)
    .then(parseRawScriptResult(request.decoder))
    .then((x) => {
      console.log('request:' + JSON.stringify(request))
      console.log('response: ' + JSON.stringify(x))
      return x
    })

const log = <A>(data: A): A => {
  console.log(JSON.stringify(data, null, 2))
  return data
}

const stringDecoder = (rawData: any): string => rawData.toString()
const numberDecoder = (rawData: any): number => parseInt(rawData.toString())

export type { ScriptRequest, ScriptSuccess, ScriptFailure, ScriptResult }
export { execute, stringDecoder, numberDecoder, log }

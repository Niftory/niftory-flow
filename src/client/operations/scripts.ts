import { flow, pipe, Util } from "#"
import { FlowHttp } from "../http"

type ExecuteScriptParams = {
  code: string
  args?: any[]
}

const query = FlowHttp.createHandler<ExecuteScriptParams>({
  method: "POST",
  path: () => `/v1/scripts`,
  body: (params) => {
    const codeBase64 = pipe(
      params.code,
      Util.String.fromUtf8ToBuffer,
      Util.Buffer.toBase64,
    )
    const argsBase64 = (params.args ?? [])
      .map((x) => JSON.stringify(x))
      .map(Util.String.fromUtf8ToBuffer)
      .map(Util.Buffer.toBase64)
    return {
      script: codeBase64,
      arguments: argsBase64,
    }
  },
})(
  flow(
    Util.String.parseBase64,
    Util.String.fromBase64ToBuffer,
    Util.Buffer.toUtf8,
    JSON.parse,
  ),
)

const ScriptOps = {
  query,
}

export { ScriptOps }

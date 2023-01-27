import { BufferUtil } from "./buffer"
import { FunctionUtil } from "./function"
import { IntLike as IntLike_, IntLikeUtil } from "./intlike"
import { StringUtil } from "./string"

namespace Util {
  export const Buffer = BufferUtil
  export const String = StringUtil
  export const IntLike = IntLikeUtil
  export type IntLike = IntLike_
  export const Function = FunctionUtil
}

export { Util }

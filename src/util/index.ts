import { BufferUtil } from "./buffer"
import { FunctionUtil } from "./function"
import { Numeric as Numeric_, NumericUtil } from "./numeric"
import { StringUtil } from "./string"

namespace Util {
  export const Buffer = BufferUtil
  export const String = StringUtil
  export const Numeric = NumericUtil
  export type Numeric = Numeric_
  export const Function = FunctionUtil
}

export { Util }

import { flow, pipe } from "./compose"

import { OptionUtils } from "./option"

import { FunctionUtils } from "./function"

import { PromiseUtils } from "./promise"

import { Utf8Util } from "./utf8"

namespace X {}

const X = {
  ...OptionUtils,
  ...FunctionUtils,
  ...PromiseUtils,
  ...Utf8Util,
}

export { X, pipe, flow }

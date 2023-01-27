import { Address } from "./codecs/address"
import { Array } from "./codecs/array"
import { identifier } from "./codecs/base"
import { Bool } from "./codecs/bool"
import * as Composite from "./codecs/composite"
import { Dictionary } from "./codecs/dictionary"
import * as Fix from "./codecs/fix"
import * as Int from "./codecs/int"
import { Optional } from "./codecs/optional"
import * as Path from "./codecs/path"
import { String } from "./codecs/string"
import { Tuple } from "./codecs/tuple"
import { Void } from "./codecs/void"

const Codec = {
  identifier,
  Void,
  Bool,
  String,
  Address,
  Optional,
  ...Int,
  ...Fix,
  Tuple,
  Array,
  Dictionary,
  ...Composite,
  ...Path,
}

export { Codec }

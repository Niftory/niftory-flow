import { flow, pipe } from "fp-ts/lib/function"

export { pipe, flow }

export function id<A>(a: A): A {
  return a
}

export function log<T>(value: T, message?: string): T {
  console.log(`${message ?? ""}` + value)
  return value
}

export function ff<A extends ReadonlyArray<unknown>, B>(
  ab: (...a: A) => B,
): (...a: A) => B
export function ff<A extends ReadonlyArray<unknown>, B, C>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
): (...a: A) => C
export function ff<A extends ReadonlyArray<unknown>, B, C, D>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
): (...a: A) => D
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
): (...a: A) => E
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E, F>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
  ef: (e: E) => F,
): (...a: A) => F
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E, F, G>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
  ef: (e: E) => F,
  fg: (f: F) => G,
): (...a: A) => G
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E, F, G, H>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
  ef: (e: E) => F,
  fg: (f: F) => G,
  gh: (g: G) => H,
): (...a: A) => H
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E, F, G, H, I>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
  ef: (e: E) => F,
  fg: (f: F) => G,
  gh: (g: G) => H,
  hi: (h: H) => I,
): (...a: A) => I
export function ff<A extends ReadonlyArray<unknown>, B, C, D, E, F, G, H, I, J>(
  ab: (...a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
  ef: (e: E) => F,
  fg: (f: F) => G,
  gh: (g: G) => H,
  hi: (h: H) => I,
  ij: (i: I) => J,
): (...a: A) => J
export function ff<
  A extends ReadonlyArray<unknown>,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
>(
  ab: (...a: A) => B,
  bc?: (b: B) => C,
  cd?: (c: C) => D,
  de?: (d: D) => E,
  ef?: (e: E) => F,
  fg?: (f: F) => G,
  gh?: (g: G) => H,
  hi?: (h: H) => I,
  ij?: (i: I) => J,
  jk?: (j: J) => K,
): (...a: A) => K
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
): (...a: A1) => A12
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
): (...a: A1) => A13
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
): (...a: A1) => A14
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
): (...a: A1) => A15
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
): (...a: A1) => A16
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
): (...a: A1) => A17
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
): (...a: A1) => A18
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
): (...a: A1) => A19
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
): (...a: A1) => A20
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
): (...a: A1) => A21
// keep going until A50
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
): (...a: A1) => A22
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
): (...a: A1) => A23
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
  A24,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
  a23a24?: (a23: A23) => A24,
): (...a: A1) => A24
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
  A24,
  A25,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
  a23a24?: (a23: A23) => A24,
  a24a25?: (a24: A24) => A25,
): (...a: A1) => A25
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
  A24,
  A25,
  A26,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
  a23a24?: (a23: A23) => A24,
  a24a25?: (a24: A24) => A25,
  a25a26?: (a25: A25) => A26,
): (...a: A1) => A26
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
  A24,
  A25,
  A26,
  A27,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
  a23a24?: (a23: A23) => A24,
  a24a25?: (a24: A24) => A25,
  a25a26?: (a25: A25) => A26,
  a26a27?: (a26: A26) => A27,
): (...a: A1) => A27
export function ff<
  A1 extends ReadonlyArray<unknown>,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  A10,
  A11,
  A12,
  A13,
  A14,
  A15,
  A16,
  A17,
  A18,
  A19,
  A20,
  A21,
  A22,
  A23,
  A24,
  A25,
  A26,
  A27,
  A28,
>(
  a1a2: (...a: A1) => A2,
  a2a3?: (a2: A2) => A3,
  a3a4?: (a3: A3) => A4,
  a4a5?: (a4: A4) => A5,
  a5a6?: (a5: A5) => A6,
  a6a7?: (a6: A6) => A7,
  a7a8?: (a7: A7) => A8,
  a8a9?: (a8: A8) => A9,
  a9a10?: (a9: A9) => A10,
  a10a11?: (a10: A10) => A11,
  a11a12?: (a11: A11) => A12,
  a12a13?: (a12: A12) => A13,
  a13a14?: (a13: A13) => A14,
  a14a15?: (a14: A14) => A15,
  a15a16?: (a15: A15) => A16,
  a16a17?: (a16: A16) => A17,
  a17a18?: (a17: A17) => A18,
  a18a19?: (a18: A18) => A19,
  a19a20?: (a19: A19) => A20,
  a20a21?: (a20: A20) => A21,
  a21a22?: (a21: A21) => A22,
  a22a23?: (a22: A22) => A23,
  a23a24?: (a23: A23) => A24,
  a24a25?: (a24: A24) => A25,
  a25a26?: (a25: A25) => A26,
  a26a27?: (a26: A26) => A27,
  a27a28?: (a27: A27) => A28,
): (...a: A1) => A28

export function ff(
  ab: Function,
  bc?: Function,
  cd?: Function,
  de?: Function,
  ef?: Function,
  fg?: Function,
  gh?: Function,
  hi?: Function,
  ij?: Function,
  a10a11?: Function,
  a11a12?: Function,
  a12a13?: Function,
  a13a14?: Function,
  a14a15?: Function,
  a15a16?: Function,
  a16a17?: Function,
  a17a18?: Function,
  a18a19?: Function,
  a19a20?: Function,
  a20a21?: Function,
  a21a22?: Function,
  a22a23?: Function,
  a23a24?: Function,
  a24a25?: Function,
  a25a26?: Function,
  a26a27?: Function,
  a27a28?: Function,
): unknown {
  switch (arguments.length) {
    case 1:
      return ab
    case 2:
      return function (this: unknown) {
        return log(bc!(log(ab.apply(this, arguments))))
      }
    case 3:
      return function (this: unknown) {
        return log(cd!(log(bc!(log(ab.apply(this, arguments))))))
      }
    case 4:
      return function (this: unknown) {
        return log(de!(log(cd!(log(bc!(log(ab.apply(this, arguments))))))))
      }
    case 5:
      return function (this: unknown) {
        return log(
          ef!(log(de!(log(cd!(log(bc!(log(ab.apply(this, arguments))))))))),
        )
      }
    case 6:
      return function (this: unknown) {
        return log(
          fg!(
            log(
              ef!(log(de!(log(cd!(log(bc!(log(ab.apply(this, arguments))))))))),
            ),
          ),
        )
      }
    case 7:
      return function (this: unknown) {
        return log(
          gh!(
            log(
              fg!(
                log(
                  ef!(
                    log(
                      de!(log(cd!(log(bc!(log(ab.apply(this, arguments))))))),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 8:
      return function (this: unknown) {
        return log(
          hi!(
            log(
              gh!(
                log(
                  fg!(
                    log(
                      ef!(
                        log(
                          de!(
                            log(cd!(log(bc!(log(ab.apply(this, arguments)))))),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 9:
      return function (this: unknown) {
        return log(
          ij!(
            log(
              hi!(
                log(
                  gh!(
                    log(
                      fg!(
                        log(
                          ef!(
                            log(
                              de!(
                                log(
                                  cd!(log(bc!(log(ab.apply(this, arguments))))),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 10:
      return function (this: unknown) {
        return log(
          a10a11!(
            log(
              ij!(
                log(
                  hi!(
                    log(
                      gh!(
                        log(
                          fg!(
                            log(
                              ef!(
                                log(
                                  de!(
                                    log(
                                      cd!(
                                        log(
                                          bc!(log(ab.apply(this, arguments))),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 11:
      return function (this: unknown) {
        return log(
          a11a12!(
            log(
              a10a11!(
                log(
                  ij!(
                    log(
                      hi!(
                        log(
                          gh!(
                            log(
                              fg!(
                                log(
                                  ef!(
                                    log(
                                      de!(
                                        log(
                                          cd!(
                                            log(
                                              bc!(
                                                log(ab.apply(this, arguments)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 12:
      return function (this: unknown) {
        return log(
          a12a13!(
            log(
              a11a12!(
                log(
                  a10a11!(
                    log(
                      ij!(
                        log(
                          hi!(
                            log(
                              gh!(
                                log(
                                  fg!(
                                    log(
                                      ef!(
                                        log(
                                          de!(
                                            log(
                                              cd!(
                                                log(
                                                  bc!(
                                                    log(
                                                      ab.apply(this, arguments),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 13:
      return function (this: unknown) {
        return log(
          a13a14!(
            log(
              a12a13!(
                log(
                  a11a12!(
                    log(
                      a10a11!(
                        log(
                          ij!(
                            log(
                              hi!(
                                log(
                                  gh!(
                                    log(
                                      fg!(
                                        log(
                                          ef!(
                                            log(
                                              de!(
                                                log(
                                                  cd!(
                                                    log(
                                                      bc!(
                                                        log(
                                                          ab.apply(
                                                            this,
                                                            arguments,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 14:
      return function (this: unknown) {
        return log(
          a14a15!(
            log(
              a13a14!(
                log(
                  a12a13!(
                    log(
                      a11a12!(
                        log(
                          a10a11!(
                            log(
                              ij!(
                                log(
                                  hi!(
                                    log(
                                      gh!(
                                        log(
                                          fg!(
                                            log(
                                              ef!(
                                                log(
                                                  de!(
                                                    log(
                                                      cd!(
                                                        log(
                                                          bc!(
                                                            log(
                                                              ab.apply(
                                                                this,
                                                                arguments,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 15:
      return function (this: unknown) {
        return log(
          a15a16!(
            log(
              a14a15!(
                log(
                  a13a14!(
                    log(
                      a12a13!(
                        log(
                          a11a12!(
                            log(
                              a10a11!(
                                log(
                                  ij!(
                                    log(
                                      hi!(
                                        log(
                                          gh!(
                                            log(
                                              fg!(
                                                log(
                                                  ef!(
                                                    log(
                                                      de!(
                                                        log(
                                                          cd!(
                                                            log(
                                                              bc!(
                                                                log(
                                                                  ab.apply(
                                                                    this,
                                                                    arguments,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 16:
      return function (this: unknown) {
        return log(
          a16a17!(
            log(
              a15a16!(
                log(
                  a14a15!(
                    log(
                      a13a14!(
                        log(
                          a12a13!(
                            log(
                              a11a12!(
                                log(
                                  a10a11!(
                                    log(
                                      ij!(
                                        log(
                                          hi!(
                                            log(
                                              gh!(
                                                log(
                                                  fg!(
                                                    log(
                                                      ef!(
                                                        log(
                                                          de!(
                                                            log(
                                                              cd!(
                                                                log(
                                                                  bc!(
                                                                    log(
                                                                      ab.apply(
                                                                        this,
                                                                        arguments,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 17:
      return function (this: unknown) {
        return log(
          a17a18!(
            log(
              a16a17!(
                log(
                  a15a16!(
                    log(
                      a14a15!(
                        log(
                          a13a14!(
                            log(
                              a12a13!(
                                log(
                                  a11a12!(
                                    log(
                                      a10a11!(
                                        log(
                                          ij!(
                                            log(
                                              hi!(
                                                log(
                                                  gh!(
                                                    log(
                                                      fg!(
                                                        log(
                                                          ef!(
                                                            log(
                                                              de!(
                                                                log(
                                                                  cd!(
                                                                    log(
                                                                      bc!(
                                                                        log(
                                                                          ab.apply(
                                                                            this,
                                                                            arguments,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 18:
      return function (this: unknown) {
        return log(
          a18a19!(
            log(
              a17a18!(
                log(
                  a16a17!(
                    log(
                      a15a16!(
                        log(
                          a14a15!(
                            log(
                              a13a14!(
                                log(
                                  a12a13!(
                                    log(
                                      a11a12!(
                                        log(
                                          a10a11!(
                                            log(
                                              ij!(
                                                log(
                                                  hi!(
                                                    log(
                                                      gh!(
                                                        log(
                                                          fg!(
                                                            log(
                                                              ef!(
                                                                log(
                                                                  de!(
                                                                    log(
                                                                      cd!(
                                                                        log(
                                                                          bc!(
                                                                            log(
                                                                              ab.apply(
                                                                                this,
                                                                                arguments,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 19:
      return function (this: unknown) {
        return log(
          a19a20!(
            log(
              a18a19!(
                log(
                  a17a18!(
                    log(
                      a16a17!(
                        log(
                          a15a16!(
                            log(
                              a14a15!(
                                log(
                                  a13a14!(
                                    log(
                                      a12a13!(
                                        log(
                                          a11a12!(
                                            log(
                                              a10a11!(
                                                log(
                                                  ij!(
                                                    log(
                                                      hi!(
                                                        log(
                                                          gh!(
                                                            log(
                                                              fg!(
                                                                log(
                                                                  ef!(
                                                                    log(
                                                                      de!(
                                                                        log(
                                                                          cd!(
                                                                            log(
                                                                              bc!(
                                                                                log(
                                                                                  ab.apply(
                                                                                    this,
                                                                                    arguments,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 20:
      return function (this: unknown) {
        return log(
          a20a21!(
            log(
              a19a20!(
                log(
                  a18a19!(
                    log(
                      a17a18!(
                        log(
                          a16a17!(
                            log(
                              a15a16!(
                                log(
                                  a14a15!(
                                    log(
                                      a13a14!(
                                        log(
                                          a12a13!(
                                            log(
                                              a11a12!(
                                                log(
                                                  a10a11!(
                                                    log(
                                                      ij!(
                                                        log(
                                                          hi!(
                                                            log(
                                                              gh!(
                                                                log(
                                                                  fg!(
                                                                    log(
                                                                      ef!(
                                                                        log(
                                                                          de!(
                                                                            log(
                                                                              cd!(
                                                                                log(
                                                                                  bc!(
                                                                                    log(
                                                                                      ab.apply(
                                                                                        this,
                                                                                        arguments,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 21:
      return function (this: unknown) {
        return log(
          a21a22!(
            log(
              a20a21!(
                log(
                  a19a20!(
                    log(
                      a18a19!(
                        log(
                          a17a18!(
                            log(
                              a16a17!(
                                log(
                                  a15a16!(
                                    log(
                                      a14a15!(
                                        log(
                                          a13a14!(
                                            log(
                                              a12a13!(
                                                log(
                                                  a11a12!(
                                                    log(
                                                      a10a11!(
                                                        log(
                                                          ij!(
                                                            log(
                                                              hi!(
                                                                log(
                                                                  gh!(
                                                                    log(
                                                                      fg!(
                                                                        log(
                                                                          ef!(
                                                                            log(
                                                                              de!(
                                                                                log(
                                                                                  cd!(
                                                                                    log(
                                                                                      bc!(
                                                                                        log(
                                                                                          ab.apply(
                                                                                            this,
                                                                                            arguments,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 22:
      return function (this: unknown) {
        return log(
          a22a23!(
            log(
              a21a22!(
                log(
                  a20a21!(
                    log(
                      a19a20!(
                        log(
                          a18a19!(
                            log(
                              a17a18!(
                                log(
                                  a16a17!(
                                    log(
                                      a15a16!(
                                        log(
                                          a14a15!(
                                            log(
                                              a13a14!(
                                                log(
                                                  a12a13!(
                                                    log(
                                                      a11a12!(
                                                        log(
                                                          a10a11!(
                                                            log(
                                                              ij!(
                                                                log(
                                                                  hi!(
                                                                    log(
                                                                      gh!(
                                                                        log(
                                                                          fg!(
                                                                            log(
                                                                              ef!(
                                                                                log(
                                                                                  de!(
                                                                                    log(
                                                                                      cd!(
                                                                                        log(
                                                                                          bc!(
                                                                                            log(
                                                                                              ab.apply(
                                                                                                this,
                                                                                                arguments,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 23:
      return function (this: unknown) {
        return log(
          a23a24!(
            log(
              a22a23!(
                log(
                  a21a22!(
                    log(
                      a20a21!(
                        log(
                          a19a20!(
                            log(
                              a18a19!(
                                log(
                                  a17a18!(
                                    log(
                                      a16a17!(
                                        log(
                                          a15a16!(
                                            log(
                                              a14a15!(
                                                log(
                                                  a13a14!(
                                                    log(
                                                      a12a13!(
                                                        log(
                                                          a11a12!(
                                                            log(
                                                              a10a11!(
                                                                log(
                                                                  ij!(
                                                                    log(
                                                                      hi!(
                                                                        log(
                                                                          gh!(
                                                                            log(
                                                                              fg!(
                                                                                log(
                                                                                  ef!(
                                                                                    log(
                                                                                      de!(
                                                                                        log(
                                                                                          cd!(
                                                                                            log(
                                                                                              bc!(
                                                                                                log(
                                                                                                  ab.apply(
                                                                                                    this,
                                                                                                    arguments,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 24:
      return function (this: unknown) {
        return log(
          a24a25!(
            log(
              a23a24!(
                log(
                  a22a23!(
                    log(
                      a21a22!(
                        log(
                          a20a21!(
                            log(
                              a19a20!(
                                log(
                                  a18a19!(
                                    log(
                                      a17a18!(
                                        log(
                                          a16a17!(
                                            log(
                                              a15a16!(
                                                log(
                                                  a14a15!(
                                                    log(
                                                      a13a14!(
                                                        log(
                                                          a12a13!(
                                                            log(
                                                              a11a12!(
                                                                log(
                                                                  a10a11!(
                                                                    log(
                                                                      ij!(
                                                                        log(
                                                                          hi!(
                                                                            log(
                                                                              gh!(
                                                                                log(
                                                                                  fg!(
                                                                                    log(
                                                                                      ef!(
                                                                                        log(
                                                                                          de!(
                                                                                            log(
                                                                                              cd!(
                                                                                                log(
                                                                                                  bc!(
                                                                                                    log(
                                                                                                      ab.apply(
                                                                                                        this,
                                                                                                        arguments,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 25:
      return function (this: unknown) {
        return log(
          a25a26!(
            log(
              a24a25!(
                log(
                  a23a24!(
                    log(
                      a22a23!(
                        log(
                          a21a22!(
                            log(
                              a20a21!(
                                log(
                                  a19a20!(
                                    log(
                                      a18a19!(
                                        log(
                                          a17a18!(
                                            log(
                                              a16a17!(
                                                log(
                                                  a15a16!(
                                                    log(
                                                      a14a15!(
                                                        log(
                                                          a13a14!(
                                                            log(
                                                              a12a13!(
                                                                log(
                                                                  a11a12!(
                                                                    log(
                                                                      a10a11!(
                                                                        log(
                                                                          ij!(
                                                                            log(
                                                                              hi!(
                                                                                log(
                                                                                  gh!(
                                                                                    log(
                                                                                      fg!(
                                                                                        log(
                                                                                          ef!(
                                                                                            log(
                                                                                              de!(
                                                                                                log(
                                                                                                  cd!(
                                                                                                    log(
                                                                                                      bc!(
                                                                                                        log(
                                                                                                          ab.apply(
                                                                                                            this,
                                                                                                            arguments,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 26:
      return function (this: unknown) {
        return log(
          a26a27!(
            log(
              a25a26!(
                log(
                  a24a25!(
                    log(
                      a23a24!(
                        log(
                          a22a23!(
                            log(
                              a21a22!(
                                log(
                                  a20a21!(
                                    log(
                                      a19a20!(
                                        log(
                                          a18a19!(
                                            log(
                                              a17a18!(
                                                log(
                                                  a16a17!(
                                                    log(
                                                      a15a16!(
                                                        log(
                                                          a14a15!(
                                                            log(
                                                              a13a14!(
                                                                log(
                                                                  a12a13!(
                                                                    log(
                                                                      a11a12!(
                                                                        log(
                                                                          a10a11!(
                                                                            log(
                                                                              ij!(
                                                                                log(
                                                                                  hi!(
                                                                                    log(
                                                                                      gh!(
                                                                                        log(
                                                                                          fg!(
                                                                                            log(
                                                                                              ef!(
                                                                                                log(
                                                                                                  de!(
                                                                                                    log(
                                                                                                      cd!(
                                                                                                        log(
                                                                                                          bc!(
                                                                                                            log(
                                                                                                              ab.apply(
                                                                                                                this,
                                                                                                                arguments,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
    case 27:
      return function (this: unknown) {
        return log(
          a27a28!(
            log(
              a26a27!(
                log(
                  a25a26!(
                    log(
                      a24a25!(
                        log(
                          a23a24!(
                            log(
                              a22a23!(
                                log(
                                  a21a22!(
                                    log(
                                      a20a21!(
                                        log(
                                          a19a20!(
                                            log(
                                              a18a19!(
                                                log(
                                                  a17a18!(
                                                    log(
                                                      a16a17!(
                                                        log(
                                                          a15a16!(
                                                            log(
                                                              a14a15!(
                                                                log(
                                                                  a13a14!(
                                                                    log(
                                                                      a12a13!(
                                                                        log(
                                                                          a11a12!(
                                                                            log(
                                                                              a10a11!(
                                                                                log(
                                                                                  ij!(
                                                                                    log(
                                                                                      hi!(
                                                                                        log(
                                                                                          gh!(
                                                                                            log(
                                                                                              fg!(
                                                                                                log(
                                                                                                  ef!(
                                                                                                    log(
                                                                                                      de!(
                                                                                                        log(
                                                                                                          cd!(
                                                                                                            log(
                                                                                                              bc!(
                                                                                                                log(
                                                                                                                  ab.apply(
                                                                                                                    this,
                                                                                                                    arguments,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      }
  }
  return
}

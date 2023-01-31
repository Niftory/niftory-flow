/*
guard(
  (x: Input) => [
    [boolean, Output1]
    [boolean, Output2]
    ...
  ]
) => (input: Input) => Output1 | Output2 | ...
*/

type GuardResolver<Output> = [boolean, Output]

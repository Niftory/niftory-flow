// interface Actor<T> {
// }

// const common = <T>(actor: Actor<T>): T => actor.common()

// type SetAdmin = Actor<SetAdmin> & {
//   mint: () => SetAdmin
//   add: () => SetAdmin
// }

// const setAdmin = (): SetAdmin => ({
//   mint: () => common(setAdmin()),
//   add: () => common(setAdmin())
// })

// setAdmin()
//   .add()
//   .mint()

// abstract class AnyActor<Config, Actor extends AnyActor<Config, Actor>> {
//   constructor(public _: { x: number; config: Config }) {}
//   abstract getThis: ({ x, config }: { x: number; config: Config }) => Actor
//   mutate = (): Actor => {
//     return this.getThis({ x: this._.x + 1, config: this._.config })
//   }
//   log = (): Actor => {
//     console.log(this._.x)
//     return this.getThis({ x: this._.x, config: this._.config })
//   }
// }

// type SetAdminConfig = {}

// class SetAdmin extends AnyActor<SetAdminConfig, SetAdmin> {
//   getThis = (_) => new SetAdmin(_)
//   mint = (params: {}): SetAdmin => this.mutate({})
//   add = (params: {}): SetAdmin => this.mutate()
// }

// const setAdmin = new SetAdmin({ x: 0, config: {} })
// setAdmin.mint().log().add().mint().log()
// setAdmin.mint().log().add().mint().log()

abstract class SemiGroup<A> {
  abstract concat(a: A, b: A): A
  abstract id(): A
}

abstract class Ord<A> extends SemiGroup<A> {
  abstract compare(a: A, b: A): -1 | 0 | 1
}

abstract class Functor<A, B> {
  abstract map(f: (a: A) => B): Functor<A, B>
}

class SuperLinkedList<A> {
  private data: A[]
  constructor(private capacity: number = 10) {
    this.data = new Array(capacity)
  }
  add(a: A) {
    this.data.push(a)
  }
}

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

abstract class AnyActor<Config, Actor extends AnyActor<Config, Actor>> {
  constructor(public _: { x: number; config: Config }) {}
  abstract getThis: ({ x, config }: { x: number; config: Config }) => Actor
  mutate = (): Actor => {
    return this.getThis({ x: this._.x + 1, config: this._.config })
  }
  log = (): Actor => {
    console.log(this._.x)
    return this.getThis({ x: this._.x, config: this._.config })
  }
}

type SetAdminConfig = {}

class SetAdmin extends AnyActor<SetAdminConfig, SetAdmin> {
  getThis = (_) => new SetAdmin(_)
  mint = (params: {}): SetAdmin => this.mutate({})
  add = (params: {}): SetAdmin => this.mutate()
}

const setAdmin = new SetAdmin({ x: 0, config: {} })
setAdmin.mint().log().add().mint().log()
setAdmin.mint().log().add().mint().log()

import { bed } from '../src/testing'

const { describe, test } = bed()

describe('test', async () => {
  test('test1', async () => {
    console.log('test')
    expect(1).toBe(1)
  })

  test('test2', async () => {
    console.log('test2')
    expect(1).toBe(1)
  })
})

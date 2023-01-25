import { glob } from 'glob'

glob('**/*.cdc', (error, filesWithJs) => {
  if (error) {
    console.log(error)
  }
  console.log(filesWithJs)
})

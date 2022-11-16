import { promises as fs } from 'fs'

const inputFile = 'package.json'
const outputFile = 'generated.cdc'

// Delete a file if it exists
const deleteFile = async (path: string) => fs.unlink(path).catch(() => {})

// Load a file from a path into a string
const loadFile = (path: string) => fs.readFile(path, 'utf8')

// Save a string to a path
const saveFile = (path: string, content: string) => fs.writeFile(path, content)

///// MAIN /////

const main = async () => {
  await deleteFile(outputFile)
  const content = await loadFile(inputFile)

  await saveFile(outputFile, content)
  console.log('Done!')
}

main().catch((err) => {
  console.error(err)
})

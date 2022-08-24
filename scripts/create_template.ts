import { promises as fs } from 'fs'

// Load a file from a path into a string
const loadFile = (path: string) => fs.readFile(path, 'utf8')

loadFile('package.json').then(console.log)

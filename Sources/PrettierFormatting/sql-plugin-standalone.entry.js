import SqlPlugin from "prettier-plugin-sql"

// Ensure Prettier's global plugin registry exists
// Then register the SQL plugin so Prettier Standalone can discover it
globalThis.prettierPlugins = globalThis.prettierPlugins || {}
globalThis.prettierPlugins.sql = SqlPlugin

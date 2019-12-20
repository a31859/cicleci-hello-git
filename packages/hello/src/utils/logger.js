const bunyan = require('bunyan')

/**
 * Logger module that uses bunyan npm package as logger
 * @module utils/logger
 */

/** Provides a logger for the API */
exports = module.exports = bunyan.createLogger({
	name: 'hello',
	level: 'trace',
})

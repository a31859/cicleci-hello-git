'use strict'

const log = require('./utils/logger')
const hapi = require('@hapi/hapi')

const config = {
	host: '0.0.0.0',
	port: 3001,
	routes: {
		cors: {
			origin: ['*'],
		},
	},
}

const server = new hapi.Server(config)


/**
 * Creates hapijs server, loads all plugins and start the server
 * @throws an error if plugin registration fails or server fails to start
 * @returns {Void} This function does not return a value
 */
async function start() {

	log.fatal('##### Starting Hello #####')

	await server.register(require('./plugins').plugins)

	await server.start()

	log.info('All plugins were loaded successfuly')

	log.info('hello is up and running on port %s', config.port)

}

start()

module.exports = server

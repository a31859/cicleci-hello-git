module.exports = {}

/**
 * hapi plugin with hello endpoint.
 * @module plugins/hello
 */

const hello = {
	handler: async (request, h) => {

		return h.response({ status: 'hello there'}).code(200)

	},
	id: 'hello-get',
	description: 'get hello',
	tags: ['api'],
}

/** Configuration object for hello endpoint */
module.exports.plugin = {
	register: (server) => {
		server.route([
			{
				method: 'GET',
				path: '/hello',
				options: hello,
			},
		])
	},
	name: 'hello-get',
}


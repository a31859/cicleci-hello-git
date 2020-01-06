module.exports = {}

/**
 * hapi plugin with hello endpoint.
 * @module plugins/hello
 */

const hello = {
	handler: async (request, h) => {

		return h.response({ status: `hello ${request.params.name | 'friend'}`}).code(200)

	},
	id: 'hello-get-2',
	description: 'get hello-2',
	tags: ['api'],
}

/** Configuration object for hello endpoint */
module.exports.plugin = {
	register: (server) => {
		server.route([
			{
				method: 'GET',
				path: '/hello/{name}',
				options: hello,
			},
		])
	},
	name: 'hello-get',
}


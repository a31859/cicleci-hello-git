const { before, after, describe, it } = exports.lab = require('@hapi/lab').script()
const { expect } = require('code')

const Hapi = require('@hapi/hapi')

const config = {
	host: '0.0.0.0',
	port: 3000,
	routes: {
		cors: {
			origin: ['*'],
		},
	},
}

const server = new Hapi.Server(config)

describe('(UNIT) GET /hello', async () => {
	before(async () => {
		await server.register(require('../plugins').plugins)
		await server.start()
	})

	after(async () => {
		await server.stop()
	})

	describe('Successful request', async () => {
		let error, resp
		before(async () => {
			try {
				resp = await server.inject({
					method: 'GET',
					url: '/hello',
				})

			} catch (err) {
				error = err
			}
		})
    
		it('Should not return an error', () => {
			expect(error).to.be.undefined()
		})

		it('Should resp status should be hello', () => {
			expect(JSON.parse(resp.payload).status).to.equal('hello')
		})

		it('Should return 200 OK', () => {
			expect(resp.statusCode).to.equal(200)
		})
    
	})
})

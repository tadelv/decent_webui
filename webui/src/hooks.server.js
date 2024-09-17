/** @type {import('@sveltejs/kit').HandleFetch} */
export async function handleFetch({ request, fetch }) {
	console.log('fetching', request.url);
	if (request.url.includes('/api')) {
		console.log('fetching', request.url);
		// clone the original request, but change the URL
		request = new Request(
			request.url.replace('/api', 'http://localhost:8888/api'),
			request
		);
	}

	return fetch(request);
}
///** @type {import('@sveltejs/kit').Handle} */
//export async function handle({ event, resolve }) {
//	console.log('handling', event.request.url);
//	// Apply CORS header for API routes
//  if (event.url.pathname.startsWith('/api')) {
//		// replace event url with the backend url
//		event.request = new Request(
//			new URL('http://localhost:8888' + event.url.pathname),
//			event.request
//		);
//		console.log('replaced:', event.request.url);
//    // Required for CORS to work
//    if(event.request.method === 'OPTIONS') {
//      return new Response(null, {
//        headers: {
//          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
//          'Access-Control-Allow-Origin': '*',
//          'Access-Control-Allow-Headers': '*',
//        }
//      });
//    }
//  }
//	const response = await resolve(event);
//	if (event.url.pathname.startsWith('/api')) {
//		response.headers.set('Access-Control-Allow-Origin', '*');
//	}
//
//	return response;
//}

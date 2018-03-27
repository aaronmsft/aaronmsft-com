addEventListener('fetch', event => {
    event.respondWith(fetchAndLog(event.request))
})

/**
* Fetch and log a given request object
* @param {Request} request
*/
async function fetchAndLog(request) {
    let src = new URL(request.url)
    let dst = new URL('https://180300static.blob.core.windows.net/aaronmsft-com')
    dst.pathname += src.pathname
    if (src.pathname.endsWith('/')) {
        dst.pathname += 'index.html'
    }
    console.log('dst:', dst.toString())

    let response = await fetch(dst, request)
    if (response.status == 404) {
        return new Response('<html><body><h1>We\'re sorry, this page was not found.</h1><p><a href="https://xkcd.com/1969/"><img src="https://imgs.xkcd.com/comics/not_available_2x.png" /></p></body></html>',
            { status: 404, statusText: 'Not found', headers: { 'Content-Type': 'text/html' } })
    }
    return response
}

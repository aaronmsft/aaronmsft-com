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
    const response = await fetch(dst, request)
    return response
}

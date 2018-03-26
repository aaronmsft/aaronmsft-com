addEventListener("fetch", event => {
    event.respondWith(fetchAndStream(event.request))
})

async function fetchAndStream(request) {
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

    // Create an identity TransformStream (a.k.a. a pipe).
    // The readable side will become our new response body.
    let { readable, writable } = new TransformStream()

    // Start pumping the body. NOTE: No await!
    streamBody(response.body, writable)

    // ... and deliver our Response while that's running.
    return new Response(readable, response)
}

async function streamBody(readable, writable) {
    let reader = readable.getReader()
    let writer = writable.getWriter()

    while (true) {
        const { done, value } = await reader.read()
        if (done) break
        // Optionally transform value's bytes here.
        await writer.write(value)
    }

    await writer.close()
}

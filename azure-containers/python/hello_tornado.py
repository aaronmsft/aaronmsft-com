import tornado.wsgi
import tornado.autoreload
import tornado.ioloop

import hello

container = tornado.wsgi.WSGIContainer(hello.app)
http_server = tornado.httpserver.HTTPServer(container)
listen_port = 8080
print('Listening on {0}'.format(listen_port))
http_server.listen(listen_port)
tornado.autoreload.add_reload_hook(lambda: print('tornado.autoreload: reloading.'))
tornado.autoreload.start()
tornado.ioloop.IOLoop.current().start()

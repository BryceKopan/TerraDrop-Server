import PerfectLib
import PerfectHTTP

public func makeRoutes() -> Routes
{
    var routes = Routes()

    routes.add(method: .get, uri: "/getDrops", handler: Handlers.getDrops)
    routes.add(method: .get, uri: "/getDisplayDrop", handler: Handlers.getDisplayDrop)
    routes.add(method: .get, uri: "/getUsers", handler: Handlers.getUsers)
    routes.add(method: .get, uri: "/getSessionData", handler: Handlers.getSessionData)
    routes.add(method: .get, uri: "/login", handler: Handlers.login)
    routes.add(method: .post, uri: "/postDrop", handler: Handlers.postDrop)

    return routes
}

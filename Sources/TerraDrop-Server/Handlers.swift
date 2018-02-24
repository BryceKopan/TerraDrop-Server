import PerfectHTTP

public class Handlers
{
    public static func handler(request: HTTPRequest, response: HTTPResponse)
    {
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
        response.completed()
    }
}

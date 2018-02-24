import PerfectHTTP
import PerfectHTTPServer

func handler(request: HTTPRequest, response: HTTPResponse)
{
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
    response.completed()
}

func handler2(request: HTTPRequest, response: HTTPResponse)
{
    response.setHeader(.contentType, value: "string")
    response.appendBody(string: "Test")
    response.completed()
}

let confData = [
    "servers": [
        //Configuration data for one server which:
        //* Serves the hello world message at <host>:<port>/
        //* Serves static files out of the "./webroot"
        //directory (which must be located in the current working directory).
        //* Performs content compression on outgoing data when appropriate.
        [
            "name":"localhost",
            "port":8181,
            "routes":[
                ["method":"get", "uri":"/", "handler":handler],
                ["method":"get", "uri":"/test", "handler":handler2],
                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
                "documentRoot":"./webroot",
                "allowResponseFilters":true]
            ],
            "filters":[
                [
                "type":"response",
                "priority":"high",
                "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                ]
            ]
        ]
    ]
]

do {
    // Launch the servers based on the configuration data.
    try HTTPServer.launch(configurationData: confData)
} catch {
        fatalError("\(error)") // fatal error launching one of the servers
}

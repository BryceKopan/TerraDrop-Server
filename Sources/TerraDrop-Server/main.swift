import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL

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
                ["method":"get", "uri":"/", "handler":Handlers.handler],
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

let testHost = "0.0.0.0"
let testUser = "root"
let testPassword = "root"
let testDB = "TerraDrop"

let mysql = MySQL()
let connected = mysql.connect(host: testHost, user: testUser, password: testPassword)

if connected
{
    print("Connected to MySQL Database")
}
else
{
    print(mysql.errorMessage())
}

do {
    // Launch the servers based on the configuration data.
    try HTTPServer.launch(configurationData: confData)
} catch {
        fatalError("\(error)") // fatal error launching one of the servers
}

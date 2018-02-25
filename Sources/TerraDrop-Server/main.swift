import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import Foundation

let confData = [
    "servers": [
        //Configuration data for one server which:
        //* Serves the hello world message at <host>:<port>/
        //* Serves static files out of the "./webroot"
        //directory (which must be located in the current working directory).
        //* Performs content compression on outgoing data when appropriate.
        [
            "name":"localhost",
            "port":8080,
            "routes":[
                ["method":"get", "uri":"/getDrops", "handler":Handlers.getDrops],
                ["method":"get", "uri":"/getUsers", "handler":Handlers.getUsers],
                ["method":"post", "uri":"/postDrop", "handler":Handlers.postDrop],
                ["method":"get", "uri":"/getDisplayDrop", "handler":Handlers.getDisplayDrop],
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

let mySQLHost = "0.0.0.0"
let mySQLUser = "root"
let mySQLPassword = "root"
let mySQLDB = "TerraDrop"

let jsonEncoder = JSONEncoder()

let mysql = MySQL()
let connected = mysql.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

if connected
{
    do 
    {
        try HTTPServer.launch(configurationData: confData)
    } 
    catch 
    {
        fatalError("\(error)")
    }
}
else
{
    print(mysql.errorMessage())
}


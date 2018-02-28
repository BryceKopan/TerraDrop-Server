import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import Foundation
import PerfectSession

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
                //["method":"post", "uri":"/login", "handler":Handlers.login],
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

/*SessionConfig.name = "TerraDropSession"
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost"

let sessionDriver = SessionMemoryDriver()
*/

let mySQLHost = "0.0.0.0"
let mySQLUser = "root"
let mySQLPassword = "root"
let mySQLDB = "TerraDrop"

let mysql = MySQL()

var connected = mysql.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

let jsonEncoder = JSONEncoder()

assert(connected, mysql.errorMessage())
    
do 
{
    try HTTPServer.launch(configurationData: confData)
} 
catch 
{
    fatalError("\(error)")
}

public func connectToDatabase() -> MySQL?
{
    let mysql1 = MySQL()

    let connected1 = mysql1.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

    if(connected1)
    {
        return mysql1
    }
    else
    {
        return nil
    }
}

public func checkConnection() -> Bool
{
    if(!mysql.ping())
    {
        print("MySQL connection lost: Reconnecting...")
        connected = mysql.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

        if(!connected)
        {
            print("Cannot connect to MySQL: \(mysql.errorMessage())");
            return false
        }
    }
    return true
}

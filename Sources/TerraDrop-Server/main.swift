import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import Foundation
import PerfectSession

let server = HTTPServer()

server.serverPort = 8080
server.addRoutes(makeRoutes())

SessionConfig.name = "TerraDropSession"
SessionConfig.idle = 86400
SessionConfig.purgeInterval = 3600

let sessionDriver = SessionMemoryDriver()

server.setRequestFilters([sessionDriver.requestFilter])
server.setResponseFilters([sessionDriver.responseFilter])

/*let confData = [
    "servers": [
        [
            "name":"localhost",
            "port":8080,
            "routes":[
                ["method":"get", "uri":"/getDrops", "handler":Handlers.getDrops],
                ["method":"get", "uri":"/getUsers", "handler":Handlers.getUsers],
                ["method":"post", "uri":"/postDrop", "handler":Handlers.postDrop],
                ["method":"get", "uri":"/getDisplayDrop", "handler":Handlers.getDisplayDrop],
                //["method":"post", "uri":"/login", "handler":Handlers.login],
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
]*/

let mySQLHost = "0.0.0.0"
let mySQLUser = "root"
let mySQLPassword = "root"
let mySQLDB = "TerraDrop"

//let mysql = MySQL()

//var connected = mysql.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

let jsonEncoder = JSONEncoder()

//assert(connected, mysql.errorMessage())
    
do 
{
    try server.start() 
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

/*public func checkConnection() -> Bool
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
}*/

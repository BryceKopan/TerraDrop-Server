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

let mySQLHost = "0.0.0.0"
let mySQLUser = "root"
let mySQLPassword = "root"
let mySQLDB = "TerraDrop"

let jsonEncoder = JSONEncoder()
    
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
    let mysql = MySQL()

    let connected = mysql.connect(host: mySQLHost, user: mySQLUser, password: mySQLPassword, db: mySQLDB)

    if(connected)
    {
        return mysql
    }
    else
    {
        return nil
    }
}

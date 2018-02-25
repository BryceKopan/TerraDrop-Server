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
            "port":8181,
            "routes":[
                ["method":"get", "uri":"/", "handler":Handlers.returnDrop],
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

let jsonEncoder = JSONEncoder()

let mysql = MySQL()
let connected = mysql.connect(host: testHost, user: testUser, password: testPassword, db: testDB)

if connected
{
    let querySuccess = mysql.query(statement: "SELECT Latitude, Longitude FROM TerraDrop WHERE idDrop = 1;")
    
    print(querySuccess)
    if(querySuccess)
    {
        print("Query Success")
        let results = mysql.storeResults()!

        print(results);

        results.forEachRow { row in
            print("Latitude: \(row[0]!)")
            print("Longitude: \(row[1]!)") 
        }
    } 

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

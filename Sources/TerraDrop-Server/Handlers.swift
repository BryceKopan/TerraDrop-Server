import PerfectHTTP
import PerfectMySQL

public class Handlers
{
    public static func getFoundDrops(request: HTTPRequest, response: HTTPResponse)
    {/*
        let debugID: String = "[GetFoundDrops]"

        guard let mysql = connectToDatabase() else
        {
            print("\(debugID) Failed to connect to database")
            return
        }

        defer
        {
            mysql.close()
        }

        let querySuccess = mysql.query(statement: "SELECT DropID, Latitude, Longitude, Color FROM TerraDrop")

        guard querySuccess else
        {
            print("\(debugID) Query Failed: \(mysql.errorMessage())")
            return
        }  

        var drops = [PartialDrop]() 
        
        let results = mysql.storeResults()!

        results.forEachRow
        {
            row in
            var drop = PartialDrop()

            drop.id = Int(row[0]!)!
            drop.latitude = Double(row[1]!)!
            drop.longitude = Double(row[2]!)!
            drop.color = String(row[3]!)!

            drops.append(drop)
        }

        do
        {
            let data = try jsonEncoder.encode(drops)

            response.setHeader(.contentType, value: "text")
            response.setBody(string: String(data: data, encoding: .utf8)!)
            response.completed()
        } 
        catch
        {
            print("\(debugID) JSON Encoding failed")
            return
        }
    */}

    public static func login(request: HTTPRequest, response: HTTPResponse)
    {
        guard let mySQL = getMySQL(for: response) else { return }

        defer { mySQL.close() }

        guard request.session != nil else
        {
            let error = Error(type: "Session Not Found")
            encode(error, to: response)
            return 
        }

        let username = String(request.param(name: "username", defaultValue: nil)!)!
        let password = String(request.param(name: "password", defaultValue: nil)!)!

        let query = "SELECT UserID, DisplayName FROM User WHERE Username = '\(username)' AND Password = '\(password)'"
        
        guard execute(query, on: mySQL, for: response) else { return }

        let results = mySQL.storeResults()!

        var user = User()

        results.forEachRow
        {
            row in

            user.userID = Int(row[0]!)!
            user.displayName = String(row[1]!)!

            request.session!.userid = String(row[0]!)!
        }
        
        encode(user, to: response)
    }

    public static func getSessionData(request: HTTPRequest, response: HTTPResponse)
    {
        guard checkLogin(of: request, for: response) else { return }

        let session = request.session!

        var sessionData = SessionData()
        sessionData.sessionID = session.token
        sessionData.userID = Int(session.userid) 

        encode(sessionData, to: response)
    }

    public static func postDrop(request: HTTPRequest, response: HTTPResponse)
    {
        guard checkLogin(of: request, for: response) else { return }

        guard let mySQL = getMySQL(for: response) else { return }

        defer { mySQL.close() }

        var drop = Drop() 

        drop.latitude = Double(request.param(name: "latitude", defaultValue: nil)!)!
        drop.longitude = Double(request.param(name: "longitude", defaultValue: nil)!)!
        drop.userID = Int(request.session!.userid)!
        drop.title = String(request.param(name: "title", defaultValue: nil)!)!
        drop.message = String(request.param(name: "message", defaultValue: nil)!)!
        drop.color = String(request.param(name: "color", defaultValue: "00FF00")!)!

        let query = "INSERT INTO TerraDrop (Hidden, Latitude, Longitude, Title, Message, UserID) VALUES (FALSE, \(drop.latitude!), \(drop.longitude!), '\(drop.title!)', '\(drop.message!)', \(drop.userID!))"

        guard execute(query, on: mySQL, for: response) else { return }

        //Replace When Figure out how to get DropID
        response.setHeader(.contentType, value: "text")
        response.setBody(string: "TRUE")
        response.completed()
    }

    public static func getDisplayDrop(request: HTTPRequest, response: HTTPResponse)
    {
        guard checkLogin(of: request, for: response) else { return }

        guard let mySQL = getMySQL(for: response) else { return }

        defer { mySQL.close() }

        guard let dropID = Int(request.param(name: "dropID", defaultValue: nil)!) else
        {
            let error = Error(type: "DropID Missing")
            encode(error, to: response)
            return
        }

        let query = "SELECT Title, Message, DisplayName FROM TerraDrop INNER JOIN User ON TerraDrop.UserID = User.UserID WHERE DropID = \(dropID)"

        guard execute(query, on: mySQL, for: response) else { return }

        let results = mySQL.storeResults()!

        var drop = Drop() 

        results.forEachRow
        {
            row in

            drop.title = String(row[0]!)!
            drop.message = String(row[1]!)!
            drop.displayName = String(row[2]!)!
        }

        encode(drop, to: response)
    }

    public static func getDrops(request: HTTPRequest, response: HTTPResponse)
    {
        guard checkLogin(of: request, for: response) else { return }

        guard let mySQL = getMySQL(for: response) else { return }

        defer { mySQL.close() }

        let query = "SELECT DropID, Latitude, Longitude, Color FROM TerraDrop"

        guard execute(query, on: mySQL, for: response) else { return }

        let results = mySQL.storeResults()!

        var drops = [Drop]() 

        results.forEachRow
        {
            row in
            var drop = Drop()

            drop.id = Int(row[0]!)!
            drop.latitude = Double(row[1]!)!
            drop.longitude = Double(row[2]!)!
            drop.color = String(row[3]!)!

            drops.append(drop)
        }

        encode(drops, to: response)
    }

    public static func getUsers(request: HTTPRequest, response: HTTPResponse)
    {
        guard checkLogin(of: request, for: response) else { return }

        guard let mySQL = getMySQL(for: response) else { return }

        defer { mySQL.close() }

        let query = "SELECT * FROM User"

        guard execute(query, on: mySQL, for: response) else { return }

        let results = mySQL.storeResults()!

        var users = [User]() 

        results.forEachRow
        {
            row in
            var user = User()

            user.userID = Int(row[0]!)!
            user.username = String(row[1]!)!
            user.password = String(row[2]!)!
            user.displayName = String(row[3]!)!

            users.append(user);
        }

        encode(users, to: response)
    }

    //Helper Functions

    private static func encode<T: Codable>(_ data: T, to response: HTTPResponse)
    {
        var myResponse: Response<T>

        if data is Error
        {
            let error = data as! Error
            print(error.type)
            myResponse = Response(error: error)
        }
        else
        {
            myResponse = Response(data: data)
        }
            
        do
        {
            let json = try jsonEncoder.encode(myResponse)
            let body = String(data: json, encoding: .utf8)!

            response.setHeader(.contentType, value: "text")
            response.setBody(string: body)
            response.completed()
        }
        catch
        {
            let error = Error(type: "JSON Encoding Failed")
            encode(error, to: response)
        }    
    }

    private static func checkLogin(of request: HTTPRequest, for response: HTTPResponse) -> Bool
    {
        guard let session = request.session else
        {
            let error = Error(type: "Session Not Found")
            encode(error, to: response)
            return false
        }

        guard Int(session.userid) != nil else
        {
            let error = Error(type: "Session Not Logged In")
            encode(error, to: response)
            return false
        }

        return true
    }

    //Temporary Function : Replace when ConnectionPool is created
    private static func getMySQL(for response: HTTPResponse) -> MySQL?
    {
        guard let mysql = connectToDatabase() else
        {
            let error = Error(type: "Database Not Found")
            encode(error, to: response)
            return nil
        }

        return mysql
    }

    private static func execute(_ query: String, on mySQL: MySQL, for response: HTTPResponse) -> Bool
    {
        guard mySQL.query(statement: query) else
        {
            let error = Error(type: "SQL Query Failed")
            encode(error, to: response)
            return false
        } 

        return true
    }
}


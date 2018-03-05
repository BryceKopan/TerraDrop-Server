import PerfectHTTP

public class Handlers
{
    /*public static func login(request: HTTPRequest, response: HTTPResponse)
    {

    }*/

    public static func getSessionData(request: HTTPRequest, response: HTTPResponse)
    {
        guard let session = request.session else
        {
            response.setBody(string: "Session Not Found")
            return response.completed()
        }

        var body = "Your Session ID is: \(session.token)"
        
        response.setBody(string: body)
        response.completed()
    }

    public static func postDrop(request: HTTPRequest, response: HTTPResponse)
    {
        let debugID: String = "[PostDrop]"

        guard let mysql = connectToDatabase() else
        {
            print("\(debugID) Failed to connect to database")
            return
        }

        defer
        {
            mysql.close()
        }

        var drop = FullDrop() 

        drop.latitude = Double(request.param(name: "latitude", defaultValue: nil)!)!
        drop.longitude = Double(request.param(name: "longitude", defaultValue: nil)!)!
        drop.userID = Int(request.param(name: "userID", defaultValue: nil)!)!
        drop.title = String(request.param(name: "title", defaultValue: nil)!)!
        drop.message = String(request.param(name: "message", defaultValue: nil)!)!
        drop.color = String(request.param(name: "color", defaultValue: "00FF00")!)!

        let querySuccess = mysql.query(statement: "INSERT INTO TerraDrop (Hidden, Latitude, Longitude, Title, Message, UserID) VALUES (FALSE, \(drop.latitude), \(drop.longitude), '\(drop.title)', '\(drop.message)', \(drop.userID))")

        guard querySuccess else
        {
            print("\(debugID) Query Failed")
            
            response.setHeader(.contentType, value: "text")
            response.appendBody(string: "FALSE")
            response.completed()
            return
        }

        response.setHeader(.contentType, value: "text")
        response.appendBody(string: "TRUE")
        response.completed()
    }

    public static func getDisplayDrop(request: HTTPRequest, response: HTTPResponse)
    {
        let debugID: String = "[GetDisplayDrop]"

        guard let mysql = connectToDatabase() else
        {
            print("\(debugID) Failed to connect to database")
            return
        }

        defer
        {
            mysql.close()
        }

        guard let dropID = Int(request.param(name: "dropID", defaultValue: nil)!) else
        {
            print("\(debugID) DropID missing")
            return
        }

        let querySuccess = mysql.query(statement: "SELECT Title, Message, DisplayName FROM TerraDrop INNER JOIN User ON TerraDrop.UserID = User.UserID WHERE DropID = \(dropID)")

        guard querySuccess else
        {
            print("\(debugID) Query Failed: \(mysql.errorMessage())")
            return
        }  

        var drop = DisplayDrop() 
        
        let results = mysql.storeResults()!

        results.forEachRow
        {
            row in

            drop.title = String(row[0]!)!
            drop.message = String(row[1]!)!
            drop.displayName = String(row[2]!)!
        }

        do
        {
            let data = try jsonEncoder.encode(drop)

            response.setHeader(.contentType, value: "text")
            response.appendBody(string: String(data: data, encoding: .utf8)!)
            response.completed()
        } 
        catch
        {
            print("\(debugID) JSON Encoding failed")
            return
        }
    }

    public static func getDrops(request: HTTPRequest, response: HTTPResponse)
    {
        /*var string = retrieve(sqlData: "SELECT DropID, Latitude, Longitude FROM TerraDrop", array: [PartialDrop])
        {
            var drops = [PartialDrop]()

            let results = mysql.storeResults()!

            results.forEachRow
            {
                row in
                var drop = PartialDrop()

                drop.id = Int(row[0]!)!
                drop.latitude = Double(row[1]!)!
                drop.longitude = Double(row[2]!)!

                drops.append(drop)
            }
            
            return drops
        }*/
        let debugID: String = "[GetDrops]"

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
            response.appendBody(string: String(data: data, encoding: .utf8)!)
            response.completed()
        } 
        catch
        {
            print("\(debugID) JSON Encoding failed")
            return
        }
    }

    public static func getUsers(request: HTTPRequest, response: HTTPResponse)
    {
        let debugID: String = "[GetUsers]"

        guard let mysql = connectToDatabase() else
        {
            print("\(debugID) Failed to connect to database")
            return
        }

        defer
        {
            mysql.close()
        }

        let querySuccess = mysql.query(statement: "SELECT * FROM User")

        guard querySuccess else
        {
            print("\(debugID) Query Failed")
            return
        }  

        var users = [FullUser]() 
        
        let results = mysql.storeResults()!

        results.forEachRow
        {
            row in
            var user = FullUser()

            user.id = Int(row[0]!)!
            user.username = String(row[1]!)!
            user.password = String(row[2]!)!
            user.displayName = String(row[3]!)!

            users.append(user);
        }

        do
        {
            let data = try jsonEncoder.encode(users)

            response.setHeader(.contentType, value: "text")
            response.appendBody(string: String(data: data, encoding: .utf8)!)
            response.completed()
        } 
        catch
        {
            print("\(debugID) JSON Encoding failed")
            return
        }
    }

    /*private static func retrieve<T>(sqlData: String, array: [T],using closure: () -> [T]) -> String
    {
        let querySuccess = mysql.query(statement: sqlData)

        guard querySuccess else
        {
            print("Query Failed: \(mysql.errorMessage())")
            return "Failed"
        }  

        do
        {
            let data = try jsonEncoder.encode(closure())

            return String(data: data, encoding: .utf8)!
        } 
        catch
        {
            print("JSON Encoding failed")
            return "Failed"
        }
    }*/
}

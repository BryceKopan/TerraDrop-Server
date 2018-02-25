import PerfectHTTP

public class Handlers
{
    public static func postDrop(request: HTTPRequest, response: HTTPResponse)
    {
        var drop = FullDrop() 

        drop.latitude = Double(request.param(name: "latitude", defaultValue: nil)!)!
        print("lat")
        drop.longitude = Double(request.param(name: "longitude", defaultValue: nil)!)!
        print("long")
        drop.userID = Int(request.param(name: "userID", defaultValue: nil)!)!
        print("user")
        drop.title = String(request.param(name: "title", defaultValue: nil)!)!
        print("title")
        drop.message = String(request.param(name: "message", defaultValue: nil)!)!
        print("meesage")

        let querySuccess = mysql.query(statement: "INSERT INTO TerraDrop (Hidden, Latitude, Longitude, Title, Message, UserID) VALUES (FALSE, \(drop.latitude), \(drop.longitude), '\(drop.title)', '\(drop.message)', \(drop.userID))")

        guard querySuccess else
        {
            print("[PostDrop] Query Failed")
            
            response.setHeader(.contentType, value: "text")
            response.appendBody(string: "FALSE")
            response.completed()
            return
        }

        response.setHeader(.contentType, value: "text")
        response.appendBody(string: "TRUE")
        response.completed()
    }

    public static func getDrops(request: HTTPRequest, response: HTTPResponse)
    {
        let querySuccess = mysql.query(statement: "SELECT DropID, Latitude, Longitude FROM TerraDrop")

        guard querySuccess else
        {
            print("[GetDrops] Query Failed")
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
            print("[GetDrops] JSON Encoding failed")
            return
        }
    }

    public static func getUsers(request: HTTPRequest, response: HTTPResponse)
    {
        let querySuccess = mysql.query(statement: "SELECT * FROM User")

        guard querySuccess else
        {
            print("[GetUsers] Query Failed")
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
            print("[GetUsers] JSON Encoding failed")
            return
        }
    }

    private static func store<T>(sqlData: String, in array: [T], using closure: () -> [T])
    {
        
    }
}

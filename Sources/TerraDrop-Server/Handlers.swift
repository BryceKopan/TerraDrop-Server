import PerfectHTTP

public class Handlers
{
    public static func handler(request: HTTPRequest, response: HTTPResponse)
    {
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
        response.completed()
    }

    public static func returnDrop(request: HTTPRequest, response: HTTPResponse)
    {
        let querySuccess = mysql.query(statement: "SELECT idDrop, Latitude, Longitude FROM TerraDrop WHERE idDrop = 1")
        guard querySuccess else
        {
            print("[ReturnDrop] Query Failed")
            return
        }  

        var drop = PartialDrop() 
        
        let results = mysql.storeResults()!

        results.forEachRow
        {
            row in
            drop.id = Int(row[0]!)!
            drop.latitude = Double(row[1]!)!
            drop.longitude = Double(row[2]!)!
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
            print("[ReturnDrop] JSON Encoding failed")
            return
        }
    }
}

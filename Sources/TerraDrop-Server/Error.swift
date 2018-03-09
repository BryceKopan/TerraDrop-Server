struct Error: Codable
{
    var type: String
    var description: String?
    var location: String?

    init(type: String, description: String? = nil, location: String? = nil)
    {
        self.type = type
        self.description = description
        self.location = location
    }
}

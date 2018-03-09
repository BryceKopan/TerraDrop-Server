struct Response<T: Codable>: Codable
{
    var error: Error?
    var data: T?

    init(error: Error? = nil, data: T? = nil)
    {
        self.error = error
        self.data = data
    }
}

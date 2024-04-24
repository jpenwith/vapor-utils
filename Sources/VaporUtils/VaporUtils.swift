import Vapor

extension CodingKey {
    var vaporValidationKey: Vapor.ValidationKey { .init(stringLiteral: stringValue) }
}

extension Vapor.Cache {
    func get<T>(_ key: String, expiresIn expirationTime: Vapor.CacheExpirationTime?, onMiss: () async throws -> T) async throws -> T where T: Codable {
        if let cached = try await get(key) as T? {
            return cached
        }
        else {
            let value = try await onMiss()

            try await set(key, to: value, expiresIn: expirationTime)

            return value
        }
    }
}


extension AsyncThrowingStream: Vapor.AsyncResponseEncodable where Element == String {
    public func encodeResponse(for request: Request) async throws -> Vapor.Response {
        let response = Response(status: .ok)
        let body = Response.Body(stream: { writer in
            Task {
                do {
                    for try await element in self {
                        _ = writer.write(.buffer(.init(data: element.data(using: .utf8)!)))
                    }

                    _ = writer.write(.end)
                }
                catch {
                    // Handle errors as needed
                }
            }
        })

        response.body = body

        return response
    }
}

extension Vapor.Request {
    func validateForm<T>(type: T.Type) throws -> T? where T : Validatable, T : Decodable {
        do {
            try T.validate(content: self)

            return try content.decode(type)
        }
        catch let error as Vapor.ValidationsError {
            session.data["error_message"] = error.failures.first?.failureDescription ?? "There was an error"

            return nil
        }
    }
    
    func validationErrorMessage() -> String? {
        guard let errorMessage = session.data["error_message"] else {
            return nil
        }

        session.data["error_message"] = nil

        return errorMessage
    }
}


extension Vapor.ClientResponse {
    var string: String? {
        guard
            let body = body
        else {
            return nil
        }
        
        let data = Data(buffer: body)
        
        return String(data: data, encoding: .utf8)
    }
}


extension Vapor.RoutesBuilder {
    public func register(_ paths: [PathComponent], collection: RouteCollection) throws {
        try grouped(paths)
            .register(collection: collection)
    }
    
    public func register(_ path: PathComponent, collection: RouteCollection) throws {
        try register([path], collection: collection)
    }
}

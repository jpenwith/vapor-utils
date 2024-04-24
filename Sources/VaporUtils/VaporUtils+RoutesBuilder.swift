//
//  VaporUtils+RoutesBuilder
//  
//
//  Created by me on 24/03/2024.
//

import Foundation
import Vapor


//Specify an AsyncRequestDecodable to have that automatically decoded and passed to your closure
public extension RoutesBuilder {
    @discardableResult
    func on<Request, Response>(
        _ method: HTTPMethod,
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @Sendable @escaping (Request, Vapor.Request) async throws -> Response
    ) -> Vapor.Route
    where Request: AsyncRequestDecodable, Response: AsyncResponseEncodable
    {
        self.on(method, path, body: body, use: { vaporRequest in
            let request = try await Request.decodeRequest(vaporRequest)

            let response = try await closure(request, vaporRequest)

            return response
        })
    }
}


public struct EmptyRequest: AsyncRequestDecodable {
    public static func decodeRequest(_ request: Request) async throws -> Self {
        .init()
    }
}


public protocol HTTPRequest: AsyncRequestDecodable {
    associatedtype Query:   Decodable = EmptyQuery
    associatedtype Content: Decodable = EmptyContent

    static func decodeRequest(parameters: Vapor.Parameters, query: Query, content: Content, vaporRequest: Vapor.Request) async throws -> Self
}

extension HTTPRequest {
    public static func decodeRequest(_ vaporRequest: Request) async throws -> Self {
        let parameters = vaporRequest.parameters
        let query = try vaporRequest.query.decode(Query.self)
        let content = try vaporRequest.content.decode(Content.self)
        
        return try await Self.decodeRequest(parameters: parameters, query: query, content: content, vaporRequest: vaporRequest)
    }
}

extension HTTPRequest where Content == EmptyContent {
    public static func decodeRequest(_ vaporRequest: Request) async throws -> Self {
        let parameters = vaporRequest.parameters
        let query = try vaporRequest.query.decode(Query.self)
        let content = Content()

        return try await Self.decodeRequest(parameters: parameters, query: query, content: content, vaporRequest: vaporRequest)
    }
}

public struct EmptyQuery: Decodable {}
public struct EmptyContent: Decodable {}

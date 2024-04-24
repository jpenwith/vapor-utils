//
//  Middlewares.LogRequestResponse
//
//
//  Created by me on 20/03/2024.
//

import Foundation
import Vapor


public extension Middlewares {
    struct LogRequestResponse: Vapor.AsyncMiddleware {
        public let shouldLogRequests: Bool
        public let shouldLogResponses: Bool
        
        public init(shouldLogRequests: Bool, shouldLogResponses: Bool) {
            self.shouldLogRequests = shouldLogRequests
            self.shouldLogResponses = shouldLogResponses
        }

        public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
            if shouldLogRequests {
                request.logger.log(level: .info, .init(stringLiteral: String(describing: request)))
            }

            let response = try await next.respond(to: request)

            if shouldLogResponses {
                var desc: [String] = []
                    desc.append("HTTP/\(response.version.major).\(response.version.minor) \(response.status.code) \(response.status.reasonPhrase)")
                    desc.append(response.headers.debugDescription)
//                    desc.append(response.body.description)
                let description = desc.joined(separator: "\n")

                request.logger.log(level: .info, .init(stringLiteral: description))
            }

            return response
        }
    }
}

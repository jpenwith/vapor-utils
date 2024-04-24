//
//  Middlewares.Redirect
//
//
//  Created by me on 20/03/2024.
//

import Foundation
import Vapor


public extension Middlewares {
    class Redirect: Vapor.AsyncMiddleware {
        public typealias If = @Sendable (Request) async throws -> Bool
        public typealias To = @Sendable (Request) async throws -> String

        let `if`: If
        let to: To

        public init(`if`: @escaping If, to: @escaping To) {
            self.`if` = `if`
            self.to = to
        }

        public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
            guard try await `if`(request) else {
                return try await next.respond(to: request)
            }

            return request.redirect(to: try await to(request))
        }
    }
}

public extension Middlewares.Redirect {
    convenience init(unless: @escaping If, to: @escaping To) {
        self.init(if: { return !(try await unless($0))}, to: to)
    }
}

public extension Middlewares.Redirect {
    convenience init(`if`: @escaping If, to: String) {
        self.init(if: `if`, to: { _ in to })
    }

    convenience init(unless: @escaping If, to: String) {
        self.init(unless: unless, to: { _ in to })
    }
}

//
//  Middlewares.RedirectLogin
//
//
//  Created by me on 20/03/2024.
//

import Foundation
import Vapor

extension Authenticatable {
    /// Basic middleware to redirect unauthenticated requests to the supplied path
    ///
    /// - parameters:
    ///    - path: The path to redirect to if the request is not authenticated
    public static func redirectLoginMiddleware(loginPath: String, nextQueryParameter: String? = nil) -> Middleware {
        redirectMiddleware(makePath: { request in
            var nextURL = URI()
            nextURL.path = loginPath

            if let nextQueryParameter = nextQueryParameter {
                nextURL.query = "\(nextQueryParameter)=\(request.url)"
            }

            return nextURL.string
        })
    }
}

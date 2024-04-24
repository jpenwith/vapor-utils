//
//  VaporUtils+Plot
//
//
//  Created by me on 24/03/2024.
//

import Foundation
import Vapor


#if canImport(Plot)
import Plot

extension Plot.HTML: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        try await Vapor.Response(
            status: .ok,
            headers: .init([("Content-Type", "text/html; charset=utf8")]),
            body: .init(stringLiteral: self.render())
        )
        .encodeResponse(for: request)
    }
}

#endif

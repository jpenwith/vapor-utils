//
//  Command.Executor
//
//
//  Created by me on 20/03/2024.
//

import Foundation
import Fluent
import Vapor


public protocol AsyncCommandWithExecutor: Vapor.AsyncCommand {
    associatedtype Executor: AsyncCommandExecutor where Executor.Signature == Self.Signature
}

extension AsyncCommandWithExecutor where Executor.Signature == Self.Signature {
    func run(using context: CommandContext, signature: Signature) async throws {
        let executor = Executor(context: context, signature: signature)
        
        try await executor.execute()
    }
}

public protocol AsyncCommandExecutor {
    associatedtype Signature: CommandSignature

    var context: CommandContext { get }
    var signature: Signature { get }

    init(context: CommandContext, signature: Signature)

    func execute() async throws
}

public extension AsyncCommandExecutor {
    var logger: Vapor.Logger {
        context.application.logger
    }

    var database: Fluent.Database {
        context.application.db
    }
    
    var client: Vapor.Client {
        context.application.client
    }
}

/**
Usage:
 
struct SomeCommand: AsyncCommandWithExecutor {
    struct Signature: CommandSignature {}

    var help: String {
        "Help message"
    }
    
    struct Executor: AsyncCommandExecutor {
        let context: CommandContext
        let signature: Signature
        
        func execute() async throws {
            logger.info("You can call .logger, .client, etc from the instance")
        }
    }
}
*/

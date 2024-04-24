//
//  Validators.ComplexPassword
//
//
//  Created by me on 06/12/2023.
//

import Foundation
import Vapor


extension ValidatorResults {
    struct ComplexPassword {
        public let isValidPassword: Bool
    }
}

extension ValidatorResults.ComplexPassword: ValidatorResult {
    var isFailure: Bool { !isValidPassword }
    
    var successDescription: String? {
        "is a sufficiently complex password"
    }
    
    var failureDescription: String? {
        "is not a sufficiently complex password"
    }
}

extension ValidatorResults.ComplexPassword {
    //https://stackoverflow.com/questions/39284607/how-to-implement-a-regex-for-password-validation-in-swift
    static fileprivate let complexityRegex = try! NSRegularExpression(pattern: "(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]", options: [])
}

extension Validator where T == String {
    static var complexPassword: Validator<T> {
        .init { input in
            guard let _ = ValidatorResults.ComplexPassword.complexityRegex.firstMatch(in: input, range: NSRange(input.startIndex..<input.endIndex, in: input)) else {
                return ValidatorResults.ComplexPassword(isValidPassword: false)
            }

            return ValidatorResults.ComplexPassword(isValidPassword: true)
        }
    }
}


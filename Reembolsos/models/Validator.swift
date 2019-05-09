//
//  Validator.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 5/9/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let allowedCharacters = "1234567890"
        let filteredPhoneNumber = phoneNumber.filter(allowedCharacters.contains)
        return phoneNumber == filteredPhoneNumber && filteredPhoneNumber.count == 9
    }
}

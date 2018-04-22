//
//  Extension.swift
//  ConvertCurrency
//
//  Created by ManTran on 4/22/18.
//  Copyright © 2018 ManTran. All rights reserved.
//

import Foundation

extension String {
    var toLocale: Locale {
        return Locale(identifier: self)
    }
}

extension Numeric {
    
    func format(numberStyle: NumberFormatter.Style = NumberFormatter.Style.decimal, locale: Locale = Locale.current) -> String? {
        if let num = self as? NSNumber {
            let formater = NumberFormatter()
            formater.numberStyle = numberStyle
            formater.locale = locale
            return formater.string(from: num)
        }
        return nil
    }
    
    func format(numberStyle: NumberFormatter.Style = NumberFormatter.Style.decimal, groupingSeparator: String = ".", decimalSeparator: String = ",") -> String? {
        if let num = self as? NSNumber {
            let formater = NumberFormatter()
            formater.numberStyle = numberStyle
            formater.groupingSeparator = groupingSeparator
            formater.decimalSeparator = decimalSeparator
            return formater.string(from: num)
        }
        return nil
    }
}

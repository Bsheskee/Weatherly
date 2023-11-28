//
//  String+Extensions.swift
//  Weatherly
//
//  Created by bartek on 28/11/2023.
//

import Foundation

extension String {
    var urlEncoded: String? {
        
        return self.replacingOccurrences(of: " ", with: "+")
    }
}


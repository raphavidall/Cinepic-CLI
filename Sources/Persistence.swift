//
//  File.swift
//  
//
//  Created by User on 15/03/24.
//

import Foundation

struct Database: Codable {
    
    struct Theme: Codable {
        let daysOfBirth: [Int: String]
        let birthMonths: [Int: String]
        let initialLetters: [String: String]
    }
    
    let themes: [String: Theme]
    
}

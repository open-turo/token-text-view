//
//  MockDataLoader.swift
//  TokenTextViewExample
//
//  Created by Chris Lee on 8/11/22.
//

import Foundation

class MockDataLoader {
    static func loadMockTokenList() -> [Token]? {
        if let path = Bundle.main.path(forResource: "MockTokens", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let decodedResult = try JSONDecoder().decode([Token].self, from: jsonData)
                return decodedResult
            } catch {
                print("Could not decode MockTokens.json")
                return nil
            }
        } else {
            print("Could not find MockTokens.json")
            return nil
        }
    }
}

import Foundation

struct Token: Codable {
    let name: String
    let identifier: String
}

class TokenInstance: NSCopying, Codable {
    let token: Token
    var range: NSRange

    init(token: Token, range: NSRange) {
        self.token = token
        self.range = range
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TokenInstance(token: self.token, range: self.range)
        return copy
    }
}

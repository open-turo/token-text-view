import UIKit

struct Attributes {
    var backgroundColor: UIColor
    var foregroundColor: UIColor
    var font: UIFont
    var kern: Int?
    var paragraphStyle: NSMutableParagraphStyle?

    var dictionary: [NSAttributedString.Key: Any] {
        var dictionary = [NSAttributedString.Key.backgroundColor: backgroundColor,
                          NSAttributedString.Key.foregroundColor: foregroundColor,
                          NSAttributedString.Key.font: font,
                          NSAttributedString.Key.kern: kern != nil ? kern as Any : 0 as Any ]

        if let paragraphStyle = paragraphStyle {
            dictionary[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }

        return dictionary
    }
}

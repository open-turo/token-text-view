import UIKit

final class TokenTextView: UITextView {

    var tokenBackgroundColor = UIColor.purple
    var tokenForegroundColor = UIColor.white
    var tokenFont = UIFont.systemFont(ofSize: 12.0)

    var defaultAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: UIColor.clear,
                                                            NSAttributedString.Key.foregroundColor: UIColor.black,
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]
    var tokenAttributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.backgroundColor: tokenBackgroundColor,
                NSAttributedString.Key.foregroundColor: tokenForegroundColor,
                NSAttributedString.Key.font: tokenFont]
    }
    
    // MARK: Public properties
    
    var tokens = [Token]() {
        didSet {
            tokenizeText()
        }
    }

    var templatedText: String {
        // Ensure all tokens ranges have been updated
        guard tokenInstances.first(where: {$0.range.upperBound - 1 >= text.count}) == nil else {
            return ""
        }

        return createTemplateText(fromTokenInstances: tokenInstances.compactMap { $0.copy() as? TokenInstance }, plainText: self.text)
    }

    // MARK: Private properties

    private var previousTextCount = 0

    private(set) var tokenOpen: String = "{{"
    private(set) var tokenClose: String = "}}"

    private var tokenInstances = [TokenInstance]()
    private var pasteboardTokenInstances = [(TokenInstance, Int)]()

    // MARK: Setup

    init(text: String? = nil, tokens: [Token] = [], tokenOpen: String = "{{", tokenClose: String = "}}") {
        super.init(frame: .zero, textContainer: nil)
        self.tokenOpen = tokenOpen
        self.tokenClose = tokenClose
        self.text = text
        defer {
            self.tokens = tokens
        }
        setup()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // In order to allow the use of standard UITextViewDelegate methods, we are using notifications to add class specific behavior that's required when text changes
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    // MARK: Public methods
    
    func insertToken(_ token: Token, at insertRange: NSRange? = nil) {
        let location = insertRange != nil ? (insertRange?.location)! : selectedRange.location
        let tokenRange = NSRange(location: location, length: token.name.count)

        // Insert the token into the text
        insertText(token.name, at: location)

        // Update existing token instances
        cleanTokenInstances(inRange: tokenRange, difference: token.name.count)
        updateRanges(after: location, difference: token.name.count)

        // Add new token instance
        tokenInstances.append(TokenInstance(token: token, range: tokenRange))

        styleText()

        // Update cursor location if needed
        if self.text.count != tokenRange.upperBound {
            self.selectedRange = NSRange(location: location + token.name.count, length: 0)
        }

        previousTextCount = self.text.count
        delegate?.textViewDidChange?(self)
    }

    // MARK: Private methods
    
    // Create stylized text from a template
    private func tokenizeText() {
        guard !text.isEmpty else { return }
        tokenInstances.removeAll()
        let templateInstances = getTemplateInstances(fromTemplate: text)
        text = templateInstances.count > 0 ? createPlainText(fromTokenInstances: templateInstances, templateText: text) : text
        previousTextCount = text.count
        styleText()
    }

    private func getTemplateInstances(fromTemplate template: String) -> [TokenInstance] {
        var templateInstances: [TokenInstance] = []

        // Gather each token instance and store in templateInstances, with range indices that include brackets (code representation)
        for token in tokens {
            let ranges = template.rangesOf(ofSubstring: tokenString(from: token.identifier))
            for range in ranges {
                templateInstances.append(TokenInstance(token: token, range: NSRange(location: range.lowerBound, length: tokenString(from: token.identifier).count)))
            }
        }

        return templateInstances
    }

    private func createPlainText(fromTokenInstances instances: [TokenInstance], templateText: String) -> String {
        var mutableText = templateText
        var sortedInstances = instances
        sortedInstances.sort { $0.range.location < $1.range.location }

        for (index, instance) in sortedInstances.enumerated() {
            // Get the String.Index values for the instance range to use in replacingCharacters
            let rangeIndices = stringIndices(ofTokenInstance: instance, messageText: mutableText)
            
            // Replace the code representation with the name representation
            mutableText = mutableText.replacingCharacters(in: rangeIndices.0...rangeIndices.1, with: instance.token.name)

            // Update tokenInstances with new instance
            tokenInstances.append(TokenInstance(token: instance.token, range: NSRange(location: instance.range.lowerBound, length: instance.token.name.count)))

            // Get the difference between the length of the new value and the old value
            let diff = tokenString(from: instance.token.identifier).count - instance.token.name.count
            
            // Because the text has been modified with the name representation replacing the code representation, we need to update subsequent token ranges to reflect that
            // We only need to update the ranges of all tokens AFTER the first
            guard index + 1 < sortedInstances.count else { break }
            for i in index + 1...sortedInstances.count - 1 {
                sortedInstances[i].range.location -= diff
            }
        }
        
        return mutableText
    }

    private func createTemplateText(fromTokenInstances instances: [TokenInstance], plainText: String) -> String {
        var mutableText = plainText
        var sortedInstances = instances
        sortedInstances.sort { $0.range.location < $1.range.location }
        
        for (index, instance) in sortedInstances.enumerated() {
            // Get the String.Index values for the instance range to use in replacingCharacters
            let rangeIndices = stringIndices(ofTokenInstance: instance, messageText: mutableText)

            // Replace the code representation with the name representation
            mutableText = mutableText.replacingCharacters(in: rangeIndices.0...rangeIndices.1, with: tokenString(from: instance.token.identifier))
            
            // Get the difference between the length of the new value and the old value
            let diff = instance.token.name.count - tokenString(from: instance.token.identifier).count
            
            // Because the text has been modified with the name representation replacing the code representation, we need to update subsequent token ranges to reflect that
            // We only need to update the ranges of all tokens AFTER the first
            guard index + 1 < sortedInstances.count else { break }
            for i in index + 1...sortedInstances.count - 1 {
                sortedInstances[i].range.location -= diff
            }
        }
        
        return mutableText
    }

    @objc private func textChanged() {
        // styleText() resets the selectedRange.location so we want to grab a reference to it here
        let location = selectedRange.location

        if text.count != previousTextCount {
            let difference = text.count - previousTextCount
            let changedRange = NSRange(location: difference < 0 ? location : location - difference, length: abs(difference))
            cleanTokenInstances(inRange: changedRange, difference: difference)
            updateRanges(after: difference < 0 ? location : location - difference, difference: difference)
            styleText()
        }

        selectedRange = NSRange(location: location, length: 0)
        previousTextCount = text.count
    }

    private func cleanTokenInstances(inRange changedRange: NSRange, difference: Int) {
        tokenInstances = difference < 0 ? tokenInstances.filter { $0.range.upperBound <= changedRange.location || $0.range.location >= changedRange.upperBound } : tokenInstances.filter({ $0.range.upperBound <= changedRange.location || $0.range.location >= changedRange.location })
    }

    private func updateRanges(after location: Int, difference: Int) {
        guard let _ = tokenInstances.first(where: { $0.range.location >= location }) else { return }

        for instance in tokenInstances {
            if instance.range.location >= location {
                instance.range.location += difference
            }
        }
    }

    private func styleText() {
        // Add common attributes
        let attributedString = NSMutableAttributedString(string: self.text)
        attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: self.text.utf16.count))

        // Add token attributes
        for instance in tokenInstances {
            attributedString.addAttributes(tokenAttributes, range: instance.range)
        }

        self.attributedText = attributedString
    }

    // MARK: Utility methods

    private func tokenString(from tokenIdentifier: String) -> String {
        "\(tokenOpen)\(tokenIdentifier)\(tokenClose)"
    }

    private func insertText(_ text: String, at location: Int) {
        let newMutableString = NSMutableString(string: self.text)
        newMutableString.insert(text, at: location)
        self.text = newMutableString as String
    }

    private func stringIndices(ofTokenInstance tokenInstance: TokenInstance, messageText: String) -> (String.Index, String.Index) {
        (messageText.index(messageText.startIndex, offsetBy: tokenInstance.range.lowerBound), messageText.index(messageText.startIndex, offsetBy: tokenInstance.range.upperBound-1))
    }

    // MARK: Pasteboard operations

    override func cut(_ sender: Any?) {
        copyTokens()
        super.cut(sender)
    }

    override func copy(_ sender: Any?) {
        copyTokens()
        super.copy(sender)
    }

    override func paste(_ sender: Any?) {
        // Check that the currently copied tokens are relevant to this paste operation
        guard pasteboardTokenInstances.filter({ UIPasteboard.general.string?.contains($0.0.token.name) ?? false }).count == pasteboardTokenInstances.count else {
            pasteboardTokenInstances.removeAll()
            super.paste(sender)
            return
        }

        let pasteRange = selectedRange
        let pasteText = UIPasteboard.general.string

        updateRanges(after: selectedRange.lowerBound, difference: pasteText?.count ?? 0)
        for tuple in pasteboardTokenInstances {
            tokenInstances.append(TokenInstance(token: tuple.0.token, range: NSRange(location: pasteRange.lowerBound + tuple.1, length: tuple.0.token.name.count)))
        }

        // Paste the text
        insertText(pasteText ?? "", at: pasteRange.location)
        styleText()

        if self.text.count != pasteRange.upperBound {
            self.selectedRange = NSRange(location: pasteRange.location + (pasteText?.count ?? 0), length: 0)
        }

        previousTextCount = self.text.count
        delegate?.textViewDidChange?(self)
    }

    private func copyTokens() {
        pasteboardTokenInstances.removeAll()
        let copiedTokenInstances = tokenInstances.filter { selectedRange.lowerBound <= $0.range.lowerBound && $0.range.upperBound <= selectedRange.upperBound }.map { $0.copy() as! TokenInstance }
        pasteboardTokenInstances = copiedTokenInstances.map {
            ($0, $0.range.location - selectedRange.location)
        }
    }
}

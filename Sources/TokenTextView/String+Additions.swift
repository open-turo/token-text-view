import Foundation

extension String {
    func rangesOf(ofSubstring substring: String) -> [NSRange] {
        var searchStartIndex = self.startIndex

        var ranges: [NSRange] = []
        while searchStartIndex < self.endIndex,
            let range = self.range(of: substring, range: searchStartIndex..<self.endIndex),
            !range.isEmpty {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            ranges.append(NSRange(location: index, length: substring.count))
            searchStartIndex = range.upperBound
        }

        return ranges
    }
}

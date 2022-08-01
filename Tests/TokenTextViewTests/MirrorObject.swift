class MirrorObject {
    let mirror: Mirror

    init(refrecting: Any) {
        mirror = Mirror(reflecting: refrecting)
    }

    func extract<T>(variableName: StaticString = #function) -> T? {
        extract(variableName: variableName, mirror: mirror)
    }

    private func extract<T>(variableName: StaticString, mirror: Mirror?) -> T? {
        guard let mirror = mirror else {
            return nil
        }

        guard let descendant = mirror.descendant("\(variableName)") as? T else {
            return extract(variableName: variableName, mirror: mirror.superclassMirror)
        }

        return descendant
    }
}

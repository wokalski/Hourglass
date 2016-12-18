extension Dictionary {
    func set(_ key: Key, _ value: Value) -> [Key: Value] {
        var result = self
        result[key] = value
        return result
    }
    func deleting(_ key: Key) -> [Key: Value] {
        var result = self
        result.removeValue(forKey: key)
        return result
    }
}

extension Dictionary where Value: Equatable {
    func deleting(_ value: Value) -> [Key: Value] {
        let keyValuePairs = self.filter { $0.value != value }
        var dict = Dictionary<Key, Value>()
        for filtered in keyValuePairs {
            dict[filtered.0] = filtered.1
        }
        return dict
    }
}

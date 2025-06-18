//
//  OrderedIndexedMap.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/18/25.
//

import Foundation

public struct OrderedIndexedMap<Index: Hashable, Value> {

    private var indices: [Index] = []
    private var values: [Value] = []

    public init() {}

    public var count: Int {
        return indices.count
    }

    public var isEmpty: Bool {
        return indices.isEmpty
    }

    public var dictionary: [Index: Value] {
        var result: [Index: Value] = [:]
        for (i, index) in indices.enumerated() {
            if i < values.count {
                result[index] = values[i]
            }
        }
        return result
    }

    public subscript(index: Index) -> Value? {
        get {
            if let i = indices.firstIndex(of: index) {
                return values[i]
            }
            return nil
        }
        set {
            if let i = indices.firstIndex(of: index) {
                if let newValue = newValue {
                    values[i] = newValue
                } else {
                    indices.remove(at: i)
                    values.remove(at: i)
                }
            } else if let newValue = newValue {
                indices.append(index)
                values.append(newValue)
            }
        }
    }

    public mutating func removeValue(for index: Index) {
        if let i = indices.firstIndex(of: index) {
            indices.remove(at: i)
            values.remove(at: i)
        }
    }

    public func contains(index: Index) -> Bool {
        return indices.contains(index)
    }

    public func orderedIndices() -> [Index] {
        return indices
    }

    public func orderedValues() -> [Value] {
        return values
    }

    public func indexOrder(of index: Index) -> Int? {
        return indices.firstIndex(of: index)
    }

    public mutating func removeAll() {
        indices.removeAll()
        values.removeAll()
    }
}

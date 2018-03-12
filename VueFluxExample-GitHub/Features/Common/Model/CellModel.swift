protocol CellModel: Hashable {
    associatedtype PrimaryKey: Hashable
    
    var primaryKey: PrimaryKey { get }
}

extension CellModel {
    var hashValue: Int {
        return primaryKey.hashValue
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.primaryKey == rhs.primaryKey
    }
}

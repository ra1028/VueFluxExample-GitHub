import UIKit

extension String {
    enum Attribute {
        case foregroundColor(UIColor)
        case font(UIFont)
        
        var key: NSAttributedStringKey {
            switch self {
            case .foregroundColor:
                return .foregroundColor
                
            case .font:
                return .font
            }
        }
        
        var value: Any {
            switch self {
            case .foregroundColor(let color):
                return color
                
            case .font(let font):
                return font
            }
        }
    }
    
    func attributed(_ attributes: Attribute...) -> NSAttributedString {
        let attributes = [NSAttributedStringKey: Any](attributes.map { ($0.key, $0.value) }, uniquingKeysWith: { $1 })
        return NSAttributedString(string: self, attributes: attributes)
    }
}

import UIKit

extension NSAttributedString {
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
    
    convenience init(string: String, attributes: [Attribute]) {
        let attributes = attributes.reduce(into: [NSAttributedStringKey: Any]()) { result, attribute in
            result[attribute.key] = attribute.value
        }
        self.init(string: string, attributes: attributes)
    }
    
    convenience init(string: String, attributes: Attribute...) {
        self.init(string: string, attributes: attributes)
    }
}

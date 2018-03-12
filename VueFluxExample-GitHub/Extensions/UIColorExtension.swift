import UIKit

extension UIColor {
    enum Background: Int64, HexColorRepresentable {
        case primaryWhite = 0xFFFFFF
        case primaryGray = 0x404448
    }
    
    enum Text: Int64, HexColorRepresentable {
        case primaryWhite = 0xffffff
        case primaryBlack = 0x202529
        case primaryGray = 0x8d8f8f
    }
    
    enum Key: Int64, HexColorRepresentable {
        case primaryBlack = 0x24292E
    }
    
    convenience init(background: Background) {
        self.init(background)
    }
    
    convenience init(text: Text) {
        self.init(text)
    }
    
    convenience init(key: Key) {
        self.init(key)
    }
}

private extension UIColor {
    convenience init<Color: HexColorRepresentable>(_ color: Color) {
        let rgb = color.rgb
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgb & 0xFF00) >> 8) / 255
        let blue = CGFloat((rgb & 0xFF)) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

private protocol HexColorRepresentable: RawRepresentable where Self.RawValue == Int64 {}

extension HexColorRepresentable {
    var rgb: Int64 {
        return rawValue
    }
}

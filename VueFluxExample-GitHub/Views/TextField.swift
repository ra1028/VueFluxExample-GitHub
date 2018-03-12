import UIKit

final class TextField: UITextField {
    @IBInspectable var textLeadingPadding: CGFloat = 0
    @IBInspectable var textTrailingPadding: CGFloat = 0
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return rect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rect(forBounds: bounds)
    }
}

private extension TextField {
    func rect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + textLeadingPadding,
            y: bounds.origin.y,
            width: bounds.width - textLeadingPadding - textTrailingPadding - clearButtonRect(forBounds: bounds).width,
            height: bounds.height
        )
    }
}

import UIKit



extension UIColor {
    
    convenience init(hex: UInt) {
       self.init(
        red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(hex & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
       )
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
       self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: CGFloat(1.0))
    }
    

}


extension UINavigationController
{
    var indexOfSection: Int? {
        return self.tabBarController?.index(ofAccessibilityElement: self)
    }
}


extension UIView {
    
    private static let kRotationAnimationKey = "rotationanimationkey"

    
    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    
    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}

import UIKit

class CustomTextField: UITextField, UITextFieldDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 10

        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        leftView = paddingView
        leftViewMode = .always

        // Set colors
        backgroundColor = UIColor.appLightGreen
        textColor = UIColor.black

        delegate = self
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.appDarkGreen.cgColor // Set border color to blue when editing
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderWidth = 0
        layer.borderColor = UIColor.white.cgColor // Reset border color to gray after editing
    }
}

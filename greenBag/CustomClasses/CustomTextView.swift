

import UIKit

class CustomTextView: UITextView, UITextViewDelegate {

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    private func commonInit() {
        // Set common styling properties here
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor

        // Add padding to the text inside the UITextView (optional)
        textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        // Other common styling options
        backgroundColor = UIColor.white
        textColor = UIColor.black

        // Set the delegate to self
        delegate = self

        // Setup placeholder label
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        // Initially hide placeholder label if text is present
        placeholderLabel.isHidden = !text.isEmpty
    }

    // MARK: - UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Adjust border width when the text view is in focus
        layer.borderWidth = 1.0
        placeholderLabel.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Revert border width when the text view loses focus
        layer.borderWidth = 0.5
        placeholderLabel.isHidden = !text.isEmpty
    }
}


import UIKit

class CustomBackButton: UIButton {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    // MARK: - Button Action

    @objc private func backButtonTapped() {
        let navigationController = findNavigationController()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper Method

    private func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let navigationController = currentResponder as? UINavigationController {
                return navigationController
            }
            responder = currentResponder.next
        }
        return nil
    }
}


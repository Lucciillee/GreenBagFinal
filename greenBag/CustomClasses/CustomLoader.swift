import UIKit

class LoaderView: UIView {
    
    static let shared = LoaderView() // Singleton instance
    
    private var activityIndicator: UIActivityIndicatorView!
    private var backgroundView: UIView!
    
    private override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupLoader()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoader()
    }
    
    private func setupLoader() {
        // Semi-transparent background
        backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.isUserInteractionEnabled = false
        addSubview(backgroundView)
        
        // Activity Indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func show(on view: UIView? = UIApplication.shared.keyWindow) {
        guard let parentView = view else { return }
        if !parentView.subviews.contains(self) { // Avoid adding the loader multiple times
            parentView.addSubview(self)
            activityIndicator.startAnimating()
        }
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
}

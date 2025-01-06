
import UIKit
import FirebaseCore
import FirebaseFirestore

// This screen lets users write reviews for products
// Users can rate products on three aspects:
// 1. Overall rating (general satisfaction)
// 2. Carbon rating (environmental impact)
// 3. Eco rating (sustainability)
class WriteReviewVC: UIViewController {
    
    // Keep track of which product we're reviewing
    var productId = ""
    
    // Set up our connection to the cloud database
    private let db = Firestore.firestore()
    
    // Store the current ratings (1-5 stars) for each category
    var currentRating = 0     // Overall product rating
    var carbonRating = 0      // Carbon footprint rating
    var ecoRating = 0         // Eco-friendliness rating
    
    // Connect to our text box where users write their review
    @IBOutlet weak var reviewTxtBox: CustomTextView!
    
    // Connect to all our star rating buttons for overall rating
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    // Connect to all our star rating buttons for carbon rating
    @IBOutlet weak var carbonStar1: UIButton!
    @IBOutlet weak var carbonStar2: UIButton!
    @IBOutlet weak var carbonStar3: UIButton!
    @IBOutlet weak var carbonStar4: UIButton!
    @IBOutlet weak var carbonStar5: UIButton!
    
    // Connect to all our star rating buttons for eco rating
    @IBOutlet weak var ecoStar1: UIButton!
    @IBOutlet weak var ecoStar2: UIButton!
    @IBOutlet weak var ecoStar3: UIButton!
    @IBOutlet weak var ecoStar4: UIButton!
    @IBOutlet weak var ecoStar5: UIButton!
    
    // When the screen loads, set up our star displays
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStars()           // Set up overall rating stars
        updateCarbonStars()     // Set up carbon rating stars
        updateEcoStars()        // Set up eco rating stars
    }
    
    // Go back to previous screen when back button is pressed
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // When the submit button is pressed
    @IBAction func submitReviewButtonPressed(_ sender: Any) {
        // Make sure the user wrote something in the review
        guard let reviewText = reviewTxtBox.text, !reviewText.isEmpty else {
            showAlert(title: "Error", message: "Please write a review")
            return
        }
        
        // Get information about who's writing the review
        let userEmail = UserModel.loggedInUserInfo.email
        let userName = UserModel.loggedInUserInfo.name
        
        // Package up all the review information
        let reviewData: [String: Any] = [
            "reviewText": reviewText,           // The written review
            "rating": currentRating,            // Overall stars (1-5)
            "userEmail": userEmail,             // Who wrote it
            "userName": userName,
            "timestamp": Date(),                // When it was written
            "productId": productId,             // Which product it's for
            "carbonRating": carbonRating,       // Carbon impact rating
            "ecoRating": ecoRating,            // Eco-friendliness rating
        ]
        
        // Save the review to our database
        db.collection("reviews").addDocument(data: reviewData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to save review: \(error.localizedDescription)")
                return
            }
            
            // If saving worked, show confirmation and go back to home
            self?.showConfirmationAlert(
                title: "Submit Review",
                message: "Are you sure you want to submit this Review?",
                confirmTitle: "Submit"
            ) {
                let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
                if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                    self?.navigationController?.setViewControllers([homeViewController], animated: true)
                }
            }
        }
    }
    
    // Handle clicks on overall rating stars
    @IBAction func star1Clicked(_ sender: Any) {
        currentRating = 1
        updateStars()
    }
    
    @IBAction func star2Clicked(_ sender: Any) {
        currentRating = 2
        updateStars()
    }
    
    @IBAction func star3Clicked(_ sender: Any) {
        currentRating = 3
        updateStars()
    }
    
    @IBAction func star4Clicked(_ sender: Any) {
        currentRating = 4
        updateStars()
    }
    
    @IBAction func star5Clicked(_ sender: Any) {
        currentRating = 5
        updateStars()
    }
    
    // Handle clicks on carbon rating stars
    @IBAction func carbonStar1Clicked(_ sender: Any) {
        carbonRating = 1
        updateCarbonStars()
    }
    
    @IBAction func carbonStar2Clicked(_ sender: Any) {
        carbonRating = 2
        updateCarbonStars()
    }
    
    @IBAction func carbonStar3Clicked(_ sender: Any) {
        carbonRating = 3
        updateCarbonStars()
    }
    
    @IBAction func carbonStar4Clicked(_ sender: Any) {
        carbonRating = 4
        updateCarbonStars()
    }
    
    @IBAction func carbonStar5Clicked(_ sender: Any) {
        carbonRating = 5
        updateCarbonStars()
    }
    
    // Handle clicks on eco rating stars
    @IBAction func ecoStar1Clicked(_ sender: Any) {
        ecoRating = 1
        updateEcoStars()
    }
    
    @IBAction func ecoStar2Clicked(_ sender: Any) {
        ecoRating = 2
        updateEcoStars()
    }
    
    @IBAction func ecoStar3Clicked(_ sender: Any) {
        ecoRating = 3
        updateEcoStars()
    }
    
    @IBAction func ecoStar4Clicked(_ sender: Any) {
        ecoRating = 4
        updateEcoStars()
    }
    
    @IBAction func ecoStar5Clicked(_ sender: Any) {
        ecoRating = 5
        updateEcoStars()
    }
    
    // Update the display of overall rating stars
    // Fills in stars up to the current rating
    func updateStars() {
        let buttons = [star1, star2, star3, star4, star5]
        buttons.enumerated().forEach { index, button in
            button?.setImage(UIImage(named: index < currentRating ? "starFilledImage" : "starUnfilledImge"), for: .normal)
        }
    }
    
    // Update the display of carbon rating stars
    private func updateCarbonStars() {
        let buttons = [carbonStar1, carbonStar2, carbonStar3, carbonStar4, carbonStar5]
        buttons.enumerated().forEach { index, button in
            button?.setImage(UIImage(named: index < carbonRating ? "starFilledImage" : "starUnfilledImge"), for: .normal)
        }
    }
    
    // Update the display of eco rating stars
    private func updateEcoStars() {
        let buttons = [ecoStar1, ecoStar2, ecoStar3, ecoStar4, ecoStar5]
        buttons.enumerated().forEach { index, button in
            button?.setImage(UIImage(named: index < ecoRating ? "starFilledImage" : "starUnfilledImge"), for: .normal)
        }
    }
    
    // Show alert messages to the user
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

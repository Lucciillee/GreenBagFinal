import UIKit
import FirebaseFirestore

// This screen shows reviews for a product
// Users can see the average rating, read reviews, and write their own review
class ProductReviewsVC: UIViewController {
    
    // Connect our UI elements to show review information
    @IBOutlet weak var productName2: UIButton!      // Shows product name
    @IBOutlet weak var star5: UIImageView!          // Fifth star in rating
    @IBOutlet weak var star4: UIImageView!          // Fourth star in rating
    @IBOutlet weak var star3: UIImageView!          // Third star in rating
    @IBOutlet weak var star2: UIImageView!          // Second star in rating
    @IBOutlet weak var star1: UIImageView!          // First star in rating
    @IBOutlet weak var reviewerName: UIButton!      // Name of reviewer
    @IBOutlet weak var averageRating: UIButton!     // Average rating of product
    @IBOutlet weak var profileImg: UIImageView!     // Reviewer's profile picture
    @IBOutlet weak var reviewerText: UILabel!       // The actual review text
    
    // Keep track of which product we're showing reviews for
    var productId: String = ""       // The ID of the product
    var productName: String = ""     // The name of the product
    
    // Set up our connection to the cloud database
    private let db = Firestore.firestore()
    
    // This runs when the screen first loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the product name at the top of the screen
        productName2.setTitle(productName, for: .normal)
        
        // Hide all review elements until we load the reviews
        // This prevents showing empty or incorrect information
        profileImg.isHidden = true
        star1.isHidden = true
        star2.isHidden = true
        star3.isHidden = true
        star4.isHidden = true
        star5.isHidden = true
        
        // Set default "no reviews" state
        averageRating.setTitle("no reviews", for: .normal)
        reviewerName.setTitle("Unknown", for: .normal)
        reviewerText.text = "No reviews yet"
        
        // Get the reviews from our database
        fetchReviewsData()
    }
    
    // Get all reviews for this product from the database
    private func fetchReviewsData() {
        // Look up reviews in Firebase where productId matches our product
        db.collection("reviews")
            .whereField("productId", isEqualTo: productId)
            .order(by: "timestamp", descending: true) // Get newest reviews first
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // If no reviews found, keep the default "no reviews" state
                guard let documents = snapshot?.documents,
                      !documents.isEmpty else {
                    return
                }
                
                // If we found reviews, show all our review UI elements
                self.profileImg.isHidden = false
                self.star1.isHidden = false
                self.star2.isHidden = false
                self.star3.isHidden = false
                self.star4.isHidden = false
                self.star5.isHidden = false
                
                // Calculate the average rating from all reviews
                // 1. Get all ratings as numbers
                // 2. Add them up and divide by how many there are
                let ratings = documents.compactMap { $0.data()["rating"] as? Int }
                let averageRatingValue = Double(ratings.reduce(0, +)) / Double(ratings.count)
                
                // Show the average rating (with one decimal place)
                self.averageRating.setTitle(String(format: "%.1f", averageRatingValue), for: .normal)
                
                // Show the most recent review
                if let mostRecentReview = documents.first {
                    let data = mostRecentReview.data()
                    let rating = data["rating"] as? Int ?? 0
                    let userName = data["userName"] as? String ?? "Unknown"
                    let review = data["reviewText"] as? String ?? "Unknown"
                    
                    // Update the display with the review information
                    self.updateStars(rating: rating)         // Show the star rating
                    self.reviewerName.setTitle(userName, for: .normal)  // Show reviewer name
                    self.reviewerText.text = review          // Show the review text
                }
            }
    }
    
    // Update the star images based on the rating
    // For example, if rating is 3, show 3 filled stars and 2 empty stars
    private func updateStars(rating: Int) {
        let stars = [star1, star2, star3, star4, star5]
        stars.enumerated().forEach { index, star in
            // For each star, fill it if its position is less than the rating
            star?.image = UIImage(named: index < rating ? "starFilledImage" : "starUnfilledImge")
        }
    }
    
    // Go back to previous screen when back button is pressed
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // Go to write review screen when write review button is pressed
    @IBAction func writeReviewButtonPressed(_ sender: Any) {
        let writeReviewVC: WriteReviewVC = WriteReviewVC.instantiate(appStoryboard: .user)
        writeReviewVC.productId = productId  // Pass along which product we're reviewing
        navigationController?.pushViewController(writeReviewVC, animated: true)
    }
}

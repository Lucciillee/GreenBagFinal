import Foundation
import FirebaseCore
struct Review {
    let rating: Int
    let reviewText: String
    let timestamp: Date
    let userId: String?
    let productId: String?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "rating": rating,
            "reviewText": reviewText,
            "timestamp": Timestamp(date: timestamp)
        ]
        
        if let userId = userId {
            dict["userId"] = userId
        }
        if let productId = productId {
            dict["productId"] = productId
        }
        
        return dict
    }
}

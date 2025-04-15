//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        7
    }
    
    private init() {}
    
    static func validate(_ timeStamp: Date, agains date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}

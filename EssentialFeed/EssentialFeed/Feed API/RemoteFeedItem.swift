//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

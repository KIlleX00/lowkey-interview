import Foundation

struct PexelsPhoto: Codable {
    let id: Int
    let url: URL
    let photographer: String
    let photographerUrl: URL
    let avgColor: String
    let alt: String
}

struct CuratedPhotosResponse: Codable {
    let nextPage: URL?
    let photos: [PexelsPhoto]
}

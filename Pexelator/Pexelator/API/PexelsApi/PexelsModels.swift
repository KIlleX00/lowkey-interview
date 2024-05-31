import Foundation

struct PexelsPhoto: Codable {
    let id: Int
    let photographer: String
    let photographerUrl: URL
    let avgColor: String
    let alt: String
    let src: Source
    
    func url(for width: CGFloat, scale: CGFloat) -> URL {
        src.original.appending(queryItems: [
            URLQueryItem(name: "w", value: "\(Int((width).rounded()))"),
            URLQueryItem(name: "dpr", value: "\(Int((scale)))")
        ])
    }
    
    struct Source: Codable {
        let original: URL
    }
}

extension PexelsPhoto: Identifiable { }

extension PexelsPhoto: Equatable {
    static func == (lhs: PexelsPhoto, rhs: PexelsPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

struct CuratedPhotosResponse: Codable {
    let nextPage: URL?
    let photos: [PexelsPhoto]
}

import Foundation

protocol PexelsApi {
    /// Provided curated photos for given page and pageSize.
    ///
    /// - Parameters:
    ///   - page: The index of a page.
    ///   - pageSize: The number of results per page.
    /// - Returns: A `RestResponse` object containing the curated photos and response headers.
    /// - Throws: An error if the search request fails.
    func curatedPhotos(page: Int, pageSize: Int) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable>

    /// Fetches the next page of results based on the previous response.
    ///
    /// - Parameter previousResponse: The previous response containing pagination information.
    /// - Returns: A `RestResponse` object containing the next page of results and response headers.
    /// - Throws: An error if the next page request fails or if the next page URL is missing.
    func nextPage(for previousResponse: CuratedPhotosResponse) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable>
}

class PexelsRestApi: PexelsApi, RestApi {
    
    // MARK: - Rest Client
    
    internal let urlSession = URLSession(configuration: .default)
    
    let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    let jsonEncoder = JSONEncoder()
    
    // MARK: - Configuration
    
    private let baseUrl = "https://api.pexels.com/v1/"
    private let apiKey = "9Dfj2abYTWA5F5EYs0fSb0pRmkrwI8rskaKcyYDXsWZI6GoSVaQwFz4g"
    
    // MARK: - Endpoints

    func curatedPhotos(page: Int, pageSize: Int) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable> {
        let urlParams = [ "per_page" : "\(pageSize)",
                          "page" : "\(page)" ]
        let request = try request(for: "curated", urlParams: urlParams)
        return try await perform(request: request)
    }
    
    func nextPage(for previousResponse: CuratedPhotosResponse) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable> {
        guard let nextPageUrl = previousResponse.nextPage else { throw PexelsApiError.nextPageMissing }
        let request = try request(url: nextPageUrl.absoluteString)
        return try await perform(request: request)
    }
    
    // MARK: - Constructing URL Request
    
    internal func request(for path: String, method: HTTPMethod = .get, urlParams: [String : String] = [:], body: Data? = nil) throws -> URLRequest {
        try request(url: "\(baseUrl)\(path)", method: method, urlParams: urlParams, body: body)
    }
    
    private func request(url: String, method: HTTPMethod = .get, urlParams: [String : String] = [:], body: Data? = nil) throws -> URLRequest {
        // Initialize URLComponenets from given url string. If this fails, we will throw invalidUrl error.
        guard var urlComponents = URLComponents(string: url) else { throw PexelsApiError.invalidUrl }
        
        // To existing queryItems, append queryItems from url parameters.
        var queryItems = urlComponents.queryItems ?? []
        queryItems += urlParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = method.rawValue
        // Don't set http body for GET http method.
        if method != .get {
            urlRequest.httpBody = body
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
}

/// An enumeration representing errors specific to the GitHub API.
enum PexelsApiError: Error {
    /// An error indicating that the URL initialization failed.
    case invalidUrl
    /// An error indicating that the next page URL is missing in the response headers.
    case nextPageMissing
}

class PexelsMockedApi: PexelsApi {
    
    static let photos = [
        PexelsPhoto(id: 1, photographer: "Cristian Gligor", avgColor: "#5D3D32", alt: "Red", src: .init(original: URL(string: "https://www.pexels.com/photo/red-24821324/")!)),
        PexelsPhoto(id: 2, photographer: "Jack Atkinson", avgColor: "#CDCFC2", alt: "FASHION EASTERN DRESSES", src: .init(original: URL(string: "https://www.pexels.com/photo/fashion-eastern-dresses-25185005/")!)),
        PexelsPhoto(id: 3, photographer: "Henry Acevedo", avgColor: "#4F4F4F", alt: "", src: .init(original: URL(string: "https://www.pexels.com/photo/a-black-and-white-photo-of-a-gate-24988214/")!))
    ]
    
    func curatedPhotos(page: Int, pageSize: Int) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable> {
        let photosResponse = CuratedPhotosResponse(nextPage: nil, photos: PexelsMockedApi.photos)
        return RestResponse(headers: EmptyResponseHeadersDecodable(headers: [:]), content: photosResponse)
    }
    
    func nextPage(for previousResponse: CuratedPhotosResponse) async throws -> RestResponse<CuratedPhotosResponse, EmptyResponseHeadersDecodable> {
        throw PexelsApiError.nextPageMissing
    }
    
}

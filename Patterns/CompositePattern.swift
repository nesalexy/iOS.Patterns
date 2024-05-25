import Foundation

struct Cat {}

// MARK: - Services
protocol CatFeed {
    func fetch(completionHandler: @escaping (Result<[Cat], Error>) -> Void)
}

final class CatFeedRemote: CatFeed {
    func fetch(completionHandler: @escaping (Result<[Cat], Error>) -> Void) {
        /// api call
        completionHandler(.success([.init(), .init()]))
    }
}

final class CatFeedStorage: CatFeed {
    func fetch(completionHandler: @escaping (Result<[Cat], Error>) -> Void) {
        /// storage call
        completionHandler(.success([.init(), .init()]))
    }
}

// MARK: - Composite pattern
final class CatFeedFallback: CatFeed {
    var source: CatFeed
    var fallbackSource: CatFeed
    
    init(source: CatFeed, fallbackSource: CatFeed) {
        self.source = source
        self.fallbackSource = fallbackSource
    }
    
    func fetch(completionHandler: @escaping (Result<[Cat], Error>) -> Void) {
        source.fetch { [weak self] result in
            guard let self = self else { return } /// throws
            switch result {
            case .success(let items):
                completionHandler(.success(items))
            case .failure:
                self.fallbackSource.fetch(completionHandler: completionHandler)
            }
        }
    }
}

// MARK: - View Controller
class CatViewController {
    
    var service: CatFeed
    
    init(service: CatFeed) {
        self.service = service
    }
    
    func viewDidLoad() {
        service.fetch { result in
            /// handle result
        }
    }
}

// MARK: - View Controller call

let vc = CatViewController(service: CatFeedFallback(source: CatFeedStorage(),
                                                    fallbackSource: CatFeedRemote()))


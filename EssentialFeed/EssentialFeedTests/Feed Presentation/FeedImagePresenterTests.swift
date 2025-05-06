//
//  EssentialFeedTests
//
//  Created by Mykola Dementiev
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Epected no view mesages")
    }
    
    func test_didStartLoadingImageData_sendsMessageToView() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        XCTAssertEqual(view.messages.count, 1)
        
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displayRetry() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helper
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view,
                                     imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        { _ in nil }
    }
    
    private class ViewSpy: FeedImageView {
        
        var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
    private struct AnyImage: Equatable {}
}

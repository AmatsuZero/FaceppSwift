import XCTest
@testable import FaceppSwift

final class FaceppSwiftTests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    
    override func setUp() {
        XCTAssert(key != nil && secret != nil)
        Facepp.Initialization(key: key!, secret: secret!)
    }
    
    func testDetect() {
        let exp = XCTestExpectation(description: "detect")
        var opt = DetectOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.returnAttributes = .all
        opt.returnLandmark = .all
        Facepp.shared?.detect(option: opt, completionHanlder: { (err, data) in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 60)
    }
    
    func testCompare() {
        XCTAssert(key != nil && secret != nil)
        
        let exp = XCTestExpectation(description: "compare")
        var opt = CompareOption()
        opt.imageUrl1 = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.imageUrl2 = URL(string: "https://bellard.org/bpg/lena5.jpg")
        
        Facepp.shared?.compare(option: opt, completionHanlder: { (err, data) in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 60)
    }
    
    static var allTests = [
        ("testDetect", testDetect),
    ]
}

import XCTest
@testable import FaceppSwift

final class FaceppSwiftTests: XCTestCase {
    func testExample() {
        let exp = XCTestExpectation(description: "detect")
        Facepp.Initialization(key: "-jE-aCYiCtmlDuv-E3JKbLBzzi2Z8flz", secret: "AcD9J28WnFz_uIJPuY4pvwarE5UEY4Tv")
        var opt = DetectOption()
        opt.imageFile = URL(fileURLWithPath: "/Users/jiangzhenhua/Pictures/Lena.jpg")
        opt.returnAttributes = .all
        opt.returnLandmark = .all
        Facepp.shared?.detect(option: opt, completionHanlder: { (err, data) in
            print(data)
            exp.fulfill()
        })
        wait(for: [exp], timeout: 100)
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

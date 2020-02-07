import XCTest
@testable import FaceppSwift

final class FaceppSwiftTests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    
    var facesetToken: String?
    var faceToken: String?
    
    override func setUp() {
        XCTAssert(key != nil && secret != nil)
        Facepp.Initialization(key: key!, secret: secret!)
    }
    
    //MARK: - Facepp API
    func testDetect() {
        let exp = XCTestExpectation(description: "detect")
        var opt = DetectOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.returnAttributes = .all
        opt.returnLandmark = .all
        Facepp.shared?.detect(option: opt, completionHanlder: { [weak self] (err, data) in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            self?.faceToken = data?.faces?.first?.faceToken
            exp.fulfill()
        })
        wait(for: [exp], timeout: 60)
    }
    
    func testCompare() {
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
    
    func testBeautify() {
        let exp = XCTestExpectation(description: "beautify")
        var opt = BeautifyOption()
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.shared?.beautify(option: opt) { (err, data) in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func testDenseLandmark() {
        let exp = XCTestExpectation(description: "Thousand Landmarks")
        var opt = ThousandLandMarkOption(returnLandMark: .all)
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.shared?.thousandLandmark(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    // 残念，XCTest无法顺序执行测试用例
    func testSearch() {
        testDetect()
        createFaceSet()
        addFace()
        search()
        if facesetToken != nil {
            deleteFaceset()
        }
    }
    
    func testFaceSetSuite() {
        testDetect()
        createFaceSet()
        updateFace()
        getFacesetDetail()
        getFaceSets()
        addFace()
        removeFace()
        deleteFaceset()
    }
    
    func search() {
        guard let setToken = facesetToken else {
            return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "search")
        var opt = SearchOption()
        opt.facesetToken = setToken
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        FaceSet.search(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    static var allTests = [
        ("testDetect", testDetect),
        ("testCompare", testCompare),
        ("testFaceSetSuite", testFaceSetSuite),
        ("testSearch", testSearch),
        ("testDenseLandmark", testDenseLandmark)
    ]
}

//MARK: - FaceSet
extension FaceppSwiftTests {
    func createFaceSet() {
        let exp = XCTestExpectation(description: "Create Faceset")
        var opt = FaceSetCreateOption()
        opt.displayName = "测试"
        FaceSet.create(option: opt) { [weak self] error, data in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            self?.facesetToken = data?.facesetToken
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func updateFace() {
        guard let setToken = facesetToken else {
            return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "Update Face Token")
        var opt = FacesetUpdateOption(facesetToken: setToken, outerId: nil)
        opt.tags = ["test"]
        FaceSet.update(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func getFacesetDetail() {
        guard let setToken = facesetToken else {
            return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "Get Faceset Detail")
        let opt = FacesetGetDetailOption(facesetToken: setToken, outerId: nil)
        FaceSet.detail(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func getFaceSets() {
        let exp = XCTestExpectation(description: "Get Facesets")
        var opt = FaceSetGetOption()
        opt.tags = ["test"]
        FaceSet.getFaceSets(option: opt, completionHanlder: { (err, data) in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 60)
    }
    
    func addFace() {
        guard let setToken = facesetToken,
            let token = faceToken else {
                return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "Add Face Token")
        let opt = FaceSetAddFaceOption(facesetToken: setToken, outerId: nil, tokens: [token])
        FaceSet.add(option: opt) { (error, resp) in
            if let err = error {
                XCTFail(err.localizedDescription)
            } else if let failure = resp?.failureDetail, !failure.isEmpty {
                XCTFail(failure.first?.reason ?? "Unknown")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func removeFace() {
        guard let setToken = facesetToken,
            let token = faceToken else {
                return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "Remove Face Token")
        let opt = FaceSetRemoveOption(facesetToken: setToken, outerId: nil, tokens: [token])
        FaceSet.remove(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func deleteFaceset() {
        guard let setToken = facesetToken else {
            return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "Delete Faceset")
        var opt = FaceSetsDeleteOption.init(facesetToken: setToken, outerId: nil)
        opt.checkEmpty = false
        FaceSet.delete(option: opt) { (error, resp) in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
}

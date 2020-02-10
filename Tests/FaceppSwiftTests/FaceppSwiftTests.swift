import XCTest
@testable import FaceppSwift

final class FaceppSwiftTests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    
    let threeDImageFile1 = ProcessInfo.processInfo.environment["3dImageFile1"]
    let threeDImageFile2 = ProcessInfo.processInfo.environment["3dImageFile2"]
    let threeDImageFile3 = ProcessInfo.processInfo.environment["3dImageFile3"]
    
    var facesetToken: String?
    var faceToken: String?
    
    override func setUp() {
        XCTAssertNotNil(key)
        XCTAssertNotNil(secret)
        Facepp.Initialization(key: key!, secret: secret!)
    }
    
    //MARK: - 人脸识别
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
        opt.imageURL1 = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.imageURL2 = URL(string: "https://bellard.org/bpg/lena5.jpg")
        
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
    
    func testFacialFeatures() {
        let exp = XCTestExpectation(description: "Facial Features")
        var opt = FacialFeaturesOption()
        opt.imageURL = URL(string: "https://bellard.org/bpg/lena5.jpg")
        Facepp.shared?.facialFeatures(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func test3DFace() {
        XCTAssertNotNil(threeDImageFile1)
        XCTAssertNotNil(threeDImageFile2)
        XCTAssertNotNil(threeDImageFile3)
        let exp = XCTestExpectation(description: "3D Face")
        var opt = ThreeDimensionFaceOption()
        opt.imageFile1 = URL(fileURLWithPath: threeDImageFile1!)
        opt.imageFile2 = URL(fileURLWithPath: threeDImageFile2!)
        opt.imageFile3 = URL(fileURLWithPath: threeDImageFile3!)
        opt.needMtl = true
        opt.needTexture = true
        Facepp.shared?.threeDimensionFace(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func testSkinAnalyze() {
        let exp = XCTestExpectation(description: "Skin Analyze")
        var opt = SkinAnalyzeOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Candye_Kane_2012.jpg/500px-Candye_Kane_2012.jpg")
        Facepp.shared?.skinanalyze(option: opt) { err, resp in
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
    
    // MARK: - 证件识别
    func testIDCard() {
        let exp1 = XCTestExpectation(description: "身份证正面检测")
        var opt = OCRIDCardOption()
        opt.needLegality = true
        opt.imageURL = URL(string: "http://5b0988e595225.cdn.sohucs.com/images/20170807/aea9cf16c3eb49349f5c56e8de583240.jpeg")
        Cardpp.idcard(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 60)
        let exp2 = XCTestExpectation(description: "身份证背面检测")
        opt.imageURL = URL(string: "https://img.maijia.com/news/main/201604/19161234v78q.jpg")
        Cardpp.idcard(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 60)
    }
    
    func testDriverLicenseV2() {
        let exp1 = XCTestExpectation(description: "驾驶证 V2")
        var opt = OCRDriverLicenseV2Option()
        opt.imageURL = URL(string: "http://pic.wodingche.com/carimg/kqfmpmny.jpeg")
        Cardpp.driverLicenseV2(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 60)
    }
    
    func testDriverLicenseV1() {
        let exp1 = XCTestExpectation(description: "驾驶证 V1")
        var opt = OCRDriverLicenseV1Option()
        opt.imageURL = URL(string: "http://pic.wodingche.com/carimg/kqfmpmny.jpeg")
        Cardpp.driverLicenseV1(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 60)
    }
    
    func testVehicleLicense() {
        let exp1 = XCTestExpectation(description: "行驶证")
        var opt = OCRVehicleLicenseOption()
        opt.imageURL = URL(string: "https://imgs.icauto.com.cn/allimg/180912/18-1P9121K31Y01.png")
        Cardpp.vehicleLicense(option: opt) { err, resp in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 60)
    }
    
    static var allTests = [
        ("testDetect", testDetect),
        ("testCompare", testCompare),
        ("testFaceSetSuite", testFaceSetSuite),
        ("testSearch", testSearch),
        ("testDenseLandmark", testDenseLandmark),
        ("testFacialFeatures", testFacialFeatures),
        ("testSkinAnalyze", testSkinAnalyze),
        ("test3DFace", test3DFace),
        ("testIDCard", testIDCard),
        ("testDriverLicenseV2", testDriverLicenseV2),
        ("testDriverLicenseV1", testDriverLicenseV1),
        ("testVehicleLicense", testVehicleLicense)
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

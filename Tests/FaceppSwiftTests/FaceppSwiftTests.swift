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
        FaceppClient.initialization(key: key!, secret: secret!)
    }
    
    // MARK: - 人脸识别
    func testDetect() {
        let exp = XCTestExpectation(description: "detect")
        let opt = FaceDetectOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.returnAttributes = .all
        opt.returnLandmark = .all
        Facepp.detect(option: opt) { [weak self] err, data in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            self?.faceToken = data?.faces?.first?.faceToken
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testCompare() {
        let exp = XCTestExpectation(description: "compare")
        var opt = CompareOption()
        opt.imageURL1 = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        opt.imageURL2 = URL(string: "https://bellard.org/bpg/lena5.jpg")
        
        Facepp.compare(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testBeautifyV1() {
        let exp = XCTestExpectation(description: "beautify V1")
        let opt = BeautifyV1Option()
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.beautifyV1(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testBeautifyV2() {
        let exp = XCTestExpectation(description: "beautify V2")
        let opt = BeautifyV2Option()
        opt.filterType = .abao
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.beautifyV2(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testDenseLandmark() {
        let exp = XCTestExpectation(description: "Thousand Landmarks")
        let opt = ThousandLandMarkOption(returnLandMark: .all)
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.thousandLandmark(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testFacialFeatures() {
        let exp = XCTestExpectation(description: "Facial Features")
        let opt = FacialFeaturesOption()
        opt.imageURL = URL(string: "https://bellard.org/bpg/lena5.jpg")
        Facepp.facialFeatures(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
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
        Facepp.threeDimensionFace(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSkinAnalyze() {
        let exp = XCTestExpectation(description: "Skin Analyze")
        let opt = SkinAnalyzeOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Candye_Kane_2012.jpg/500px-Candye_Kane_2012.jpg")
        Facepp.skinAnalyze(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSkinAnalyzeAdvance() {
        let exp = XCTestExpectation(description: "Skin Analyze Advanced")
        let opt = SkinAnalyzeAdvancedOption()
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Candye_Kane_2012.jpg/500px-Candye_Kane_2012.jpg")
        Facepp.skinAnalyzeAdvanced(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    // 残念，XCTest无法顺序执行测试用例
    func testSearch() {
        // 免费账号有并发数限制
        testDetect()
        Thread.sleep(forTimeInterval: 3)
        createFaceSet()
        Thread.sleep(forTimeInterval: 3)
        addFace()
        Thread.sleep(forTimeInterval: 3)
        search()
        Thread.sleep(forTimeInterval: 3)
        if facesetToken != nil {
            deleteFaceset()
        }
    }
    
    func testFaceSetSuite() {
        testDetect()
        Thread.sleep(forTimeInterval: 3)
        createFaceSet()
        Thread.sleep(forTimeInterval: 3)
        updateFace()
        Thread.sleep(forTimeInterval: 3)
        getFacesetDetail()
        Thread.sleep(forTimeInterval: 3)
        getFaceSets()
        Thread.sleep(forTimeInterval: 3)
        addFace()
        Thread.sleep(forTimeInterval: 3)
        removeFace()
        Thread.sleep(forTimeInterval: 3)
        deleteFaceset()
    }
    
    func search() {
        guard let setToken = facesetToken else {
            return XCTFail("没有Face Token")
        }
        let exp = XCTestExpectation(description: "search")
        let opt = SearchOption()
        opt.facesetToken = setToken
        opt.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png")
        FaceSet.search(option: opt) { err, _ in
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
        let opt = OCRIDCardOption()
        opt.needLegality = true
        opt.imageURL = URL(string: "http://5b0988e595225.cdn.sohucs.com/images/20170807/aea9cf16c3eb49349f5c56e8de583240.jpeg")
        Cardpp.idCard(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
        let exp2 = XCTestExpectation(description: "身份证背面检测")
        opt.imageURL = URL(string: "https://img.maijia.com/news/main/201604/19161234v78q.jpg")
        Cardpp.idCard(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp2.fulfill()
        }.request()
        wait(for: [exp2], timeout: 60)
    }
    
    func testDriverLicenseV2() {
        let exp1 = XCTestExpectation(description: "驾驶证 V2")
        let opt = OCRDriverLicenseV2Option()
        opt.imageURL = URL(string: "http://pic.wodingche.com/carimg/kqfmpmny.jpeg")
        Cardpp.driverLicenseV2(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
    }
    
    func testDriverLicenseV1() {
        let exp1 = XCTestExpectation(description: "驾驶证 V1")
        let opt = OCRDriverLicenseV1Option()
        opt.imageURL = URL(string: "http://pic.wodingche.com/carimg/kqfmpmny.jpeg")
        Cardpp.driverLicenseV1(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
    }
    
    func testVehicleLicense() {
        let exp1 = XCTestExpectation(description: "行驶证")
        let opt = OCRVehicleLicenseOption()
        opt.imageURL = URL(string: "https://imgs.icauto.com.cn/allimg/180912/18-1P9121K31Y01.png")
        Cardpp.vehicleLicense(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
    }
    
    func testBankCardV1() {
        let exp1 = XCTestExpectation(description: "银行卡 V1")
        let opt = OCRBankCardV1Option()
        opt.imageURL = URL(string: "http://www.kaka868.com/FileLocal/2016002144-jsd.jpg")
        Cardpp.bankCardV1(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
    }
    
    func testBankCardBeta() {
        let exp1 = XCTestExpectation(description: "银行卡 Beta")
        let opt = OCRBankCardBetaOption()
        opt.imageURL = URL(string: "http://www.kaka868.com/FileLocal/2016002144-jsd.jpg")
        Cardpp.bankCardBeta(option: opt) { err, _ in
            if let err = err {
                XCTFail(err.localizedDescription)
            }
            exp1.fulfill()
        }.request()
        wait(for: [exp1], timeout: 60)
    }
    
    // MARK: - 人体识别
    func testHumanBodyDetect() {
        let exp = XCTestExpectation(description: "人体检测")
        let opt = HumanBodyDetectOption()
        opt.returnAttributes = .all
        opt.imageURL = URL(string: "https://n.sinaimg.cn/ent/transform/250/w630h420/20191209/3df3-iknhexh9270759.jpg")
        FaceppHumanBody.bodyDetect(option: opt) { error, _ in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSkeleton() {
        let exp = XCTestExpectation(description: "骨骼检测")
        let opt = SkeletonDetectOption()
        opt.imageURL = URL(string: "https://media1.popsugar-assets.com/files/thumbor/HzBtiO1fUBvUZeSBAp0NgA4DbEA/fit-in/1024x1024/filters:format_auto-!!-:strip_icc-!!-/2018/10/23/118/n/4981322/60cff8a45bce7e60adda52.01948560_/i/Australian-Models-Victoria-Secret-Fashion-Show-2018.jpg")
        FaceppHumanBody.skeleton(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSegmentV1() {
        let exp = XCTestExpectation(description: "增加抠出人像的图片 V1")
        let opt = HumanBodySegmentV1Option()
        opt.imageURL = URL(string: "http://www.dabanzixun.com/wp-content/uploads/2017/11/600-x-500-3.jpg")
        FaceppHumanBody.segmentV1(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSegmentV2() {
        let exp = XCTestExpectation(description: "增加抠出人像的图片 V2")
        let opt = HumanBodySegmentV2Option()
        opt.returnGrayScale = .grayScaleAndFigure
        opt.imageURL = URL(string: "http://www.dabanzixun.com/wp-content/uploads/2017/11/600-x-500-3.jpg")
        FaceppHumanBody.segmentV2(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testGesture() {
        let exp = XCTestExpectation(description: "手势检测")
        let opt = HumanBodyGestureOption()
        opt.imageURL = URL(string: "https://p1.pstatp.com/large/pgc-image/1538558842994169f7673b6")
        FaceppHumanBody.gesture(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    // MARK: - 图像识别
    func testLicensePlate() {
        let exp = XCTestExpectation(description: "车牌识别")
        let opt = ImageppLicensePlateOption()
        opt.imageURL = URL(string: "https://www.threetong.com/uploads/allimg/160514/9-160514164SDY.jpg")
        Imagepp.licensePlate(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testRecognizeRText() {
        let exp = XCTestExpectation(description: "文字识别")
        let opt = ImageppRecognizeTextOption()
        opt.imageURL = URL(string: "http://img.yao51.com/jiankangtuku/obhfpfpejz.jpeg")
        Imagepp.recognizeText(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testDetectSceneAndObject() {
        let exp = XCTestExpectation(description: "识别图片场景和图片主体")
        let opt = ImageppDetectScenceAndObjectOption()
        opt.imageURL = URL(string: "https://pic.pingguolv.com/uploads/allimg/160715/124-160G5141339.jpg")
        Imagepp.detectsceneandobject(option: opt) { error, resp in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    func testSerialization() {
        let exp = XCTestExpectation(description: "序列化测试")
        let opt = BeautifyV1Option()
        opt.imageURL = URL(string: "http://qimg.hxnews.com/2019/1021/1571650243816.jpg")
        Facepp.beautifyV1(option: opt) { err, resp in
            guard err == nil else {
                XCTFail(err!.localizedDescription)
                return;
            }
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
            defer {
                if FileManager.default.fileExists(atPath: url.path) {
                   try? FileManager.default.removeItem(at: url)
                }
                exp.fulfill()
            }
            do {
                try resp?.archive(at: url)
                let newResp = try BeautifyResponse.unarchinve(at: url)
                XCTAssert(resp == newResp)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }.request()
        wait(for: [exp], timeout: 60)
    }
    
    static var allTests = [
        ("testDetect", testDetect),
        ("testCompare", testCompare),
        ("testFaceSetSuite", testFaceSetSuite),
        ("testSearch", testSearch),
        ("testBeautifyV1", testBeautifyV1),
        ("testBeautifyV2", testBeautifyV2),
        ("testDenseLandmark", testDenseLandmark),
        ("testFacialFeatures", testFacialFeatures),
        ("testSkinAnalyze", testSkinAnalyze),
        ("test3DFace", test3DFace),
        ("testIDCard", testIDCard),
        ("testDriverLicenseV2", testDriverLicenseV2),
        ("testDriverLicenseV1", testDriverLicenseV1),
        ("testVehicleLicense", testVehicleLicense),
        ("testBankCardV1", testBankCardV1),
        ("testBankCardBeta", testBankCardBeta),
        ("testHumanBodyDetect", testHumanBodyDetect),
        ("testSkeleton", testSkeleton),
        ("testSegmentV1", testSegmentV1),
        ("testSegmentV2", testSegmentV2),
        ("testLicensePlate", testLicensePlate),
        ("testRecognizeRText", testRecognizeRText),
        ("testSkinAnalyzeAdvance", testSkinAnalyzeAdvance),
        ("testSerialization", testSerialization)
    ]
}

// MARK: - FaceSet
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
        let opt = FacesetUpdateOption(facesetToken: setToken, outerId: nil)
        opt.tags = ["test"]
        FaceSet.update(option: opt) { error, _ in
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
        FaceSet.detail(option: opt) { error, _ in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
    
    func getFaceSets() {
        let exp = XCTestExpectation(description: "Get Facesets")
        let opt = FaceSetGetOption(tags: ["test"])
        FaceSet.getFaceSets(option: opt, completionHanlder: { (err, _) in
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
        FaceSet.remove(option: opt) { error, _ in
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
        let opt = FaceSetsDeleteOption.init(facesetToken: setToken, outerId: nil)
        opt.checkEmpty = false
        FaceSet.delete(option: opt) { (error, _) in
            if let err = error {
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60)
    }
}

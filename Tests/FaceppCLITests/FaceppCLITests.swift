import XCTest
import class Foundation.Bundle

final class FaceppCLITests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    let facesetToken = ProcessInfo.processInfo.environment["facesetToken"]
    let faceToken = ProcessInfo.processInfo.environment["faceToken"]
    
    func testSetup() throws {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
        XCTAssertNotNil(key)
        XCTAssertNotNil(secret)
        
        _ = try getProcess([
            "setup",
            "--key", key!,
            "--secret", secret!
        ])
        guard let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("com.daubertjiang.faceppcli")
            .appendingPathComponent("config") else {
                return
        }
        let data = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: String]
        XCTAssertEqual(obj?["key"]! == key, obj?["secret"] == secret)
    }
    
    func testFaceDetect() throws {
        let output = try getProcess([
            "face", "detect",
            "--enable-metrics",
            "--url", "http://5b0988e595225.cdn.sohucs.com/images/20191103/9c9bdf0a89a44cb59d16cae007951af8.jpeg",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testCompare() throws {
        let output = try getProcess([
            "face", "compare",
            "--enable-metrics",
            "--url1",
            "https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Lenna_%28test_image%29.png/440px-Lenna_%28test_image%29.png",
            "--url2", "https://bellard.org/bpg/lena5.jpg"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testFeatures() throws {
        let output = try getProcess([
            "face", "features",
            "--enable-metrics",
            "--url", "https://bellard.org/bpg/lena5.jpg",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testDenseLandmark() throws {
        let output = try getProcess([
            "face", "thousandlandmark",
            "--enable-metrics",
            "-T", "30.0",
            "--url", "https://bellard.org/bpg/lena5.jpg",
            "nose"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testSkinAnalyze() throws {
        let output = try getProcess([
            "face", "analyze",
            "--enable-metrics",
            "-T", "30.0",
            "--url",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Candye_Kane_2012.jpg/500px-Candye_Kane_2012.jpg",
            "--enable-advanced"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testModel() throws {
        let url = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let output = try getProcess([
            "face", "model",
            "--url1",
            "https://bellard.org/bpg/lena5.jpg",
            "--output",
            "\(url.path)/output",
            "--mtl",
            "--texture",
        ])
        XCTAssertNotNil(output)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testGetAllFacesets() throws {
        let output = try getProcess([
            "faceset", "all",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testCreateFaceset() throws {
        let output = try getProcess([
            "faceset", "create",
            "--tags",
            "cli,daubert",
            "--data",
            "测试",
            "--name",
            "测试集合"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testGetFacesetDetail() throws {
        XCTAssertNotNil(facesetToken)
        let output = try getProcess([
            "faceset", "detail",
            "--token",
            facesetToken!,
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testUpdateFaceset() throws {
        XCTAssertNotNil(facesetToken)
        let output = try getProcess([
            "faceset", "update",
            "--token",
            facesetToken!,
            "--name",
            "CLI测试"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testAddFace() throws {
        XCTAssertNotNil(facesetToken)
        XCTAssertNotNil(faceToken)
        let output = try getProcess([
            "faceset", "add",
            "--token",
            facesetToken!,
            "\(faceToken!)"
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testRemoveFace() throws {
        XCTAssertNotNil(facesetToken)
        let output = try getProcess([
            "faceset", "remove",
            "--token",
            facesetToken!,
            "RemoveAllFaceTokens",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testBodyDetect() throws {
        let output = try getProcess([
            "body", "detect",
            "--url",
            "https://n.sinaimg.cn/ent/transform/250/w630h420/20191209/3df3-iknhexh9270759.jpg",
            "gender",
            "upper_body_cloth",
            "upper_body_cloth",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testSkeleton() throws {
        let output = try getProcess([
            "body", "skeleton",
            "--url", "https://media1.popsugar-assets.com/files/thumbor/HzBtiO1fUBvUZeSBAp0NgA4DbEA/fit-in/1024x1024/filters:format_auto-!!-:strip_icc-!!-/2018/10/23/118/n/4981322/60cff8a45bce7e60adda52.01948560_/i/Australian-Models-Victoria-Secret-Fashion-Show-2018.jpg",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testSegment() throws {
        let output = try getProcess([
            "body", "segment",
            "--apiVersion", "1",
            "--url", "http://www.dabanzixun.com/wp-content/uploads/2017/11/600-x-500-3.jpg",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    func testGesture() throws {
        let output = try getProcess([
            "body", "gesture",
            "--url", "https://p1.pstatp.com/large/pgc-image/1538558842994169f7673b6",
        ])
        XCTAssertNotNil(output)
        print(output!)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    func getProcess(_ arguments: [String]) throws -> String? {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
        let fooBinary = productsDirectory.appendingPathComponent("FaceppCLI")
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments
        
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    static var allTests = [
        ("testSetup", testSetup),
        ("testFaceDetect", testFaceDetect),
        ("testCompare", testCompare),
        ("testFeatures", testFeatures),
        ("testDenseLandmark", testDenseLandmark),
        ("testSkinAnalyze", testSkinAnalyze),
        ("testModel", testModel),
        ("testCreateFaceset", testCreateFaceset),
        ("testGetAllFacesets", testGetAllFacesets),
        ("testGetFacesetDetail", testGetFacesetDetail),
        ("testUpdateFaceset", testUpdateFaceset),
        ("testAddFace", testAddFace),
        ("testRemoveFace", testRemoveFace),
        ("testBodyDetect", testBodyDetect),
        ("testSkeleton", testSkeleton),
        ("testSegment", testSegment),
        ("testGesture", testGesture)
    ]
}

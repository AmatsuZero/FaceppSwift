import XCTest
import class Foundation.Bundle

final class FaceppCLITests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    
    override func setUp() {
        XCTAssertNotNil(key)
        XCTAssertNotNil(secret)
    }
    
    func testSetup() throws {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
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
        let output = try getProcess([
            "face", "model",
            "--url1",
            "https://bellard.org/bpg/lena5.jpg",
            "--output",
            "~/Desktop/output",
            "--mtl",
            " ",
        ])
        XCTAssertNotNil(output)
//        print(output!)
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
        ("testModel", testModel)
    ]
}

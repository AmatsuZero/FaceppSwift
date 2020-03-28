//
//  FaceppImage.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/23.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public final class FaceppImageLoader<T: FaceppRequestConfigProtocol, R: FaceppResponseProtocol>: ObservableObject {

    @Published public var response: R?

    @Published public var error: Error?

    @Published public var isLoading: Bool = false

    public var option: T

    var currentTask: URLSessionTask?

    public init(option: T) {
        self.option = option
    }

    public func load() {
        guard let request = option as? RequestProtocol,
            currentTask == nil else {
                return
        }
        let handler: (Error?, R?) -> Void = { [weak self] error, resp in
            self?.error = error
            self?.response = resp
            self?.isLoading = false
            self?.currentTask = nil
        }
        isLoading = true
        currentTask = FaceppClient.shared?.parse(option: request, completionHandler: handler)
    }

    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
}

// MARK: - 人脸识别
/// 人脸识别
public typealias FaceDetectLoader = FaceppImageLoader<FaceDetectOption, FaceDetectResponse>
/// 人脸比较
public typealias FaceCompareLoader = FaceppImageLoader<CompareOption, CompareResponse>
/// 美颜 V1
public typealias BeautifyV1Loader = FaceppImageLoader<BeautifyV1Option, BeautifyResponse>
/// 美颜 V2
public typealias BeautifyV2Loader = FaceppImageLoader<BeautifyV2Option, BeautifyResponse>
/// 稠密关键点
public typealias ThousandLandmarkLoader = FaceppImageLoader<ThousandLandMarkOption, ThousandLandmarkResponse>
/// 面部特征
public typealias FacialFeaturesLoader = FaceppImageLoader<FacialFeaturesOption, FacialFeaturesResponse>
/// 3D人脸
public typealias ThreeDimensionFaceLoader = FaceppImageLoader<ThreeDimensionFaceOption, ThreeDimensionFaceResponse>
/// 皮肤分析
public typealias SkinAnalyzeLoader = FaceppImageLoader<SkinAnalyzeOption, SkinAnalyzeResponse>
/// 皮肤分析进阶版
public typealias SkinAnalyzeAdvancedLoader = FaceppImageLoader<SkinAnalyzeAdvancedOption, SkinAnalyzeResponse>
/// 人脸搜索
public typealias SearchFaceLoader = FaceppImageLoader<SearchOption, SearchResponse>
/// 为检测出的某一个人脸添加标识信息
public typealias FaceSetUserIdLoader = FaceppImageLoader<FaceSetUserIdOption, FaceSetUserIdResponse>
/// 获取一个人脸的关联信息
public typealias FaceGetDetailLoader = FaceppImageLoader<FaceGetDetailOption, FaceGetDetailResponse>
/// 得出人脸关键点
public typealias FaceAnalyzeLoader = FaceppImageLoader<FaceAnalyzeOption, FaceAnalyzeResponse>

// MARK: - 人体识别
/// 人体检测
public typealias BodyDetectLoader = FaceppImageLoader<HumanBodyDetectOption, HumanBodyDetectResponse>
/// 骨骼检测
public typealias SkeletonLoader = FaceppImageLoader<SkeletonDetectOption, SkeletonDetectResponse>
/// 人体扣像 V1
public typealias BodySegmentV1Loader = FaceppImageLoader<HumanBodySegmentV1Option, HumanBodySegmentResponse>
/// 人体扣像 V2
public typealias BodySegmentV2Loader = FaceppImageLoader<HumanBodySegmentV2Option, HumanBodySegmentResponse>
/// 手势识别
public typealias HandGestureLoader = FaceppImageLoader<HumanBodyGestureOption, HumanBodyGestureResponse>

// MARK: - 图像识别
/// 车牌识别
public typealias LicensePlateLoader = FaceppImageLoader<ImageppLicensePlateOption, ImageppLicensePlateResponse>
/// 人脸合并
public typealias MergeFaceLoader = FaceppImageLoader<ImageppMergeFaceOption, ImageppMergeFaceResponse>
/// 文字识别
public typealias RecognizeTextLoader = FaceppImageLoader<ImageppRecognizeTextOption, ImagepprecognizeTextResponse>
/// 静物识别
public typealias DetectSceneAndObjectLoader = FaceppImageLoader<
    ImageppDetectScenceAndObjectOption,
    ImageppDetectScenceAndObjectResponse>

// MARK: - 证件识别
/// 身份证识别
public typealias IDCardLoader = FaceppImageLoader<OCRIDCardOption, OCRIDCardResponse>
/// 驾驶证 V2
public typealias DriverLicenseV2Loader = FaceppImageLoader<OCRDriverLicenseV2Option, OCRDriverLicenseV2Response>
/// 驾驶证 V1
public typealias DriverLicenseV1Loader = FaceppImageLoader<OCRDriverLicenseV1Option, OCRDriverLicenseV1Response>
/// 行驶证
public typealias VehicleLicenseLoader = FaceppImageLoader<OCRVehicleLicenseOption, OCRVehicleLicenseResponse>
/// 银行卡 V1
public typealias BankCardV1Loader = FaceppImageLoader<OCRBankCardV1Option, OCRBankCardResponse>
/// 银行卡 V2
public typealias BankCardBetaLoader = FaceppImageLoader<OCRBankCardBetaOption, OCRBankCardResponse>
/// 模板识别
public typealias CustomTemplateLoader = FaceppImageLoader<OCRTemplateOption, OCRTemplateResponse>

// MARK: - 人脸集合
/// 创建人脸集合
public typealias FacesetCreateLoader = FaceppImageLoader<FaceSetCreateOption, FaceSetCreateResponse>
/// 获取人脸集合
public typealias FacesetGetAllLoader = FaceppImageLoader<FaceSetGetOption, FacesetGetDetailResponse>
/// 删除人脸集合
public typealias FacesetDeleteLoader = FaceppImageLoader<FaceSetsDeleteOption, FacesetDeleteResponse>
/// 获取 Faceset 详情
public typealias FacesetGetDetailLoader = FaceppImageLoader<FacesetGetDetailOption, FacesetGetDetailResponse>
/// 更新一个人脸集合的属性
public typealias FacesetUpdateLoader = FaceppImageLoader<FacesetUpdateOption, FaceSetUpdateResponse>
/// 删除人脸
public typealias FacesetRemoveFaceLoader = FaceppImageLoader<FaceSetRemoveOption, FaceSetRemoveResponse>
/// 删除人脸 （异步）
public typealias FacesetRemoveFaceAsyncLoader = FaceppImageLoader<FaceSetAsyncRemoveOption, FaceSetAsyncOperationResponse>
/// 添加人脸
public typealias FacesetAddFaceLoader = FaceppImageLoader<FaceSetAddFaceOption, FaceSetAddFaceResponse>
/// 添加人脸 （异步）
public typealias FacesetAddFaceAsyncLoader = FaceppImageLoader<FaceSetAsyncAddFaceOption, FaceSetAsyncOperationResponse>
/// 任务查询
public typealias FacesetTaskQueryLoader = FaceppImageLoader<FaceSetTaskQueryOption, FaceSetTaskQueryResponse>

// MARK: 人脸相册
/// 创建相册
public typealias FaceAlbumCreateLoader = FaceppImageLoader<CreateFaceAlbumOption, FaceAlbumBaseReeponse>
/// 删除相册
public typealias FaceAlbumDeleteLoader = FaceppImageLoader<FaceAlbumDeleteOption, FaceAlbumBaseReeponse>
/// 查看所有相册
public typealias FaceAlbumGetAllLoader = FaceppImageLoader<FaceAblumGetAllOption, FaceAblumGetAllResponse>
/// 添加图片
public typealias FaceAlbumAddImageLoader = FaceppImageLoader<FaceAlbumAddImageOption, FaceAlbumAddImageResponse>
/// 添加图片 （异步）
public typealias FaceAlbumAddImageAsnycLoader = FaceppImageLoader<
    FaceAlbumAddImageAsyncOption,
    FaceAlbumAddImageAsyncResponse>
/// 添加图片结果查询（异步）
public typealias FaceAlbumAddImageTaskQueryLoader = FaceppImageLoader<
    FaceAlbumAddImageTaskQueryOption,
    FaceAlbumAddImageTaskQueryResponse>
/// 移除人脸
public typealias FaceAlbumDeleteFaceLoader = FaceppImageLoader<FaceAlbumDeleteFaceOption, FaceAlbumDeleteFaceResponse>
/// 寻找相似分组
public typealias FaceAlbumFindCandidateLoader = FaceppImageLoader<FaceAlbumFindCandidateOption, FaceAlbumFindCandidateResponse>
/// 聚类人脸（异步)
public typealias FaceAlbumGroupFaceLoader = FaceppImageLoader<FaceAlbumGroupFaceOption, FaceAlbumGroupFaceResponse>
/// 聚类人脸结果查询（异步）
public typealias FaceAlbumGroupFaceTaskQueryLoader = FaceppImageLoader<
    FaceAlbumGroupFaceOption,
    FaceAlbumGroupFaceResponse>
/// 搜索图片（异步）
public typealias FaceAlbumSearchImageLoader = FaceppImageLoader<
    FaceAlbumSearchImageOption,
    FaceAlbumSearchImageResponse>
/// 搜索图片结果查询（异步）
public typealias FaceAlbumSearchImageTaskQuery = FaceppImageLoader<
    FaceAlbumSearchImageTaskQueryOption,
    FaceAlbumSearchImageTaskQueryResponse>
/// 查看人脸详情
public typealias FaceAlbumGetFaceDetailLoader = FaceppImageLoader<FaceAblbumGetFaceDetailOption, FaceAblbumGetFaceDetailResponse>
/// 查看图片详情
public typealias FaceAlbumGetImageDetailLoader = FaceppImageLoader<FaceAlbumGetImageDetailOption, FaceAlbumGetImageDetailResponse>
//// 查看相册详情
public typealias FaceAlbumGetDetailLoader = FaceppImageLoader<FaceAlbumGetAlbumDetailOption, FaceAlbumGetAlbumDetailResponse>
/// 更新人脸
public typealias FaceAlbumUpdateFaceLoader = FaceppImageLoader<FaceAlbumUpdateFaceOption, FaceAlbumUpdateFaceResponse>

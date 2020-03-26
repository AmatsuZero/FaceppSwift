//
//  FaceppImageLoader.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/23.
//

import Combine
import Foundation

private var fppCombineProtocolKey: Void?

public protocol FaceppCombineProtocol {
    associatedtype ResponseType: FaceppResponseProtocol
    func fetch() -> Future<ResponseType, Error>
}

extension FaceDetectOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceDetectResponse, Error> {
        return Future<FaceDetectResponse, Error> { promise in
            Facepp.detect(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension CompareOption: FaceppCombineProtocol {
    public func fetch() -> Future<CompareResponse, Error> {
        return Future<CompareResponse, Error> { promise in
            Facepp.compare(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ThousandLandMarkOption: FaceppCombineProtocol {
    public func fetch() -> Future<ThousandLandmarkResponse, Error> {
        return Future<ThousandLandmarkResponse, Error> { promise in
            Facepp.thousandLandmark(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension BeautifyV1Option: FaceppCombineProtocol {
    public func fetch() -> Future<BeautifyResponse, Error> {
        return Future<BeautifyResponse, Error> { promise in
            Facepp.beautifyV1(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension FacialFeaturesOption: FaceppCombineProtocol {
    public func fetch() -> Future<FacialFeaturesResponse, Error> {
        return Future<FacialFeaturesResponse, Error> { promise in
            Facepp.facialFeatures(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension SearchOption: FaceppCombineProtocol {
    public func fetch() -> Future<SearchResponse, Error> {
        return Future<SearchResponse, Error> { promise in
            FaceSet.search(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension SkinAnalyzeOption: FaceppCombineProtocol {
    public func fetch() -> Future<SkinAnalyzeResponse, Error> {
        return Future<SkinAnalyzeResponse, Error> { promise in
            Facepp.skinAnalyze(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension SkinAnalyzeAdvancedOption: FaceppCombineProtocol {
    public func fetch() -> Future<SkinAnalyzeAdvancedResponse, Error> {        
        return Future<SkinAnalyzeAdvancedResponse, Error> { promise in
            Facepp.skinAnalyzeAdvanced(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ThreeDimensionFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<ThreeDimensionFaceResponse, Error> {
        return Future<ThreeDimensionFaceResponse, Error> { promise in
            Facepp.threeDimensionFace(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension FaceSetGetOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetsGetResponse, Error> {
        return Future<FaceSetsGetResponse, Error> { promise in
            FaceSet.getFaceSets(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetsDeleteOption: FaceppCombineProtocol {
    public func fetch() -> Future<FacesetDeleteResponse, Error> {
        return Future<FacesetDeleteResponse, Error> { promise in
            FaceSet.delete(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FacesetGetDetailOption: FaceppCombineProtocol {
    public func fetch() -> Future<FacesetGetDetailResponse, Error> {
        return Future<FacesetGetDetailResponse, Error> { promise in
            FaceSet.detail(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FacesetUpdateOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetUpdateResponse, Error> {
        return Future<FaceSetUpdateResponse, Error> { promise in
            FaceSet.update(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetRemoveOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetRemoveResponse, Error> {
        return Future<FaceSetRemoveResponse, Error> { promise in
            FaceSet.remove(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetAddFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetAddFaceResponse, Error> {
        return Future<FaceSetAddFaceResponse, Error> { promise in
            FaceSet.add(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetCreateOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetCreateResponse, Error> {
        return Future<FaceSetCreateResponse, Error> { promise in
            FaceSet.create(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetTaskQueryOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceSetTaskQueryResponse, Error> {
        return Future<FaceSetTaskQueryResponse, Error> { promise in
            FaceSet.asyncQuery(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetAsyncAddFaceOption {
    public func fetch() -> Future<FaceSetAsyncOperationResponse, Error> {
        return Future<FaceSetAsyncOperationResponse, Error> { promise in
            FaceSet.asyncAdd(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceSetAsyncRemoveOption {
    public func fetch() -> Future<FaceSetAsyncOperationResponse, Error> {
        return Future<FaceSetAsyncOperationResponse, Error> { promise in
            FaceSet.asyncRemove(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension HumanBodyGestureOption: FaceppCombineProtocol {
    public func fetch() -> Future<HumanBodyGestureResponse, Error> {
        return Future<HumanBodyGestureResponse, Error> { promise in
            FaceppHumanBody.gesture(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension HumanBodyDetectOption: FaceppCombineProtocol {
    public func fetch() -> Future<HumanBodyDetectResponse, Error> {
        return Future<HumanBodyDetectResponse, Error> { promise in
            FaceppHumanBody.bodyDetect(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension HumanBodySegmentV1Option: FaceppCombineProtocol {
    public func fetch() -> Future<HumanBodySegmentResponse, Error> {
        return Future<HumanBodySegmentResponse, Error> { promise in
            FaceppHumanBody.segmentV1(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension HumanBodySegmentV2Option: FaceppCombineProtocol {
    public func fetch() -> Future<HumanBodySegmentResponse, Error> {
        return Future<HumanBodySegmentResponse, Error> { promise in
            FaceppHumanBody.segmentV2(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension SkeletonDetectOption: FaceppCombineProtocol {
    public func fetch() -> Future<SkeletonDetectResponse, Error> {
        return Future<SkeletonDetectResponse, Error> { promise in
            FaceppHumanBody.skeleton(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRBankCardV1Option: FaceppCombineProtocol {
    public func fetch() -> Future<OCRBankCardResponse, Error> {
        return Future<OCRBankCardResponse, Error> { promise in
            Cardpp.bankCardV1(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRBankCardBetaOption: FaceppCombineProtocol {
    public func fetch() -> Future<OCRBankCardResponse, Error> {
        return Future<OCRBankCardResponse, Error> { promise in
            Cardpp.bankCardBeta(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRDriverLicenseV1Option: FaceppCombineProtocol {
    public func fetch() -> Future<OCRDriverLicenseV1Response, Error> {
        return Future<OCRDriverLicenseV1Response, Error> { promise in
            Cardpp.driverLicenseV1(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRDriverLicenseV2Option: FaceppCombineProtocol {
    public func fetch() -> Future<OCRDriverLicenseV2Response, Error> {
        return Future<OCRDriverLicenseV2Response, Error> { promise in
            Cardpp.driverLicenseV2(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRIDCardOption: FaceppCombineProtocol {
    public func fetch() -> Future<OCRIDCardResponse, Error> {
        return Future<OCRIDCardResponse, Error> { promise in
            Cardpp.idCard(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRTemplateOption: FaceppCombineProtocol {
    public func fetch() -> Future<OCRTemplateResponse, Error> {
        return Future<OCRTemplateResponse, Error> { promise in
            Cardpp.templateOCR(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension OCRVehicleLicenseOption: FaceppCombineProtocol {
    public func fetch() -> Future<OCRVehicleLicenseResponse, Error> {
        return Future<OCRVehicleLicenseResponse, Error> { promise in
            Cardpp.vehicleLicense(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ImageppDetectScenceAndObjectOption: FaceppCombineProtocol {
    public func fetch() -> Future<ImageppDetectScenceAndObjectResponse, Error> {
        return Future<ImageppDetectScenceAndObjectResponse, Error> { promise in
            Imagepp.detectsceneandobject(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ImageppLicensePlateOption: FaceppCombineProtocol {
    public func fetch() -> Future<ImageppLicensePlateResponse, Error> {
        return Future<ImageppLicensePlateResponse, Error> { promise in
            Imagepp.licensePlate(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ImageppMergeFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<ImageppMergeFaceResponse, Error> {
        return Future<ImageppMergeFaceResponse, Error> { promise in
            Imagepp.mergeFace(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension ImageppRecognizeTextOption: FaceppCombineProtocol {
    public func fetch() -> Future<ImagepprecognizeTextResponse, Error> {
        return Future<ImagepprecognizeTextResponse, Error> { promise in
            Imagepp.recognizeText(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }.request()
        }
    }
}

extension CreateFaceAlbumOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumBaseReeponse, Error> {
        return Future<FaceAlbumBaseReeponse, Error> { promise in
            FaceAlbum.create(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumDeleteOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumBaseReeponse, Error> {
        return Future<FaceAlbumBaseReeponse, Error> { promise in
            FaceAlbum.delete(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumFindCandidateOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumFindCandidateResponse, Error> {
        return Future<FaceAlbumFindCandidateResponse, Error> { promise in
            FaceAlbum.findCandidate(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumSearchImageOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumSearchImageResponse, Error> {
        return Future<FaceAlbumSearchImageResponse, Error> { promise in
            FaceAlbum.searchImage(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumSearchImageTaskQueryOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumSearchImageTaskQueryResponse, Error> {
        return Future<FaceAlbumSearchImageTaskQueryResponse, Error> { promise in
            FaceAlbum.searchImageTaskQuery(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumUpdateFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumUpdateFaceResponse, Error> {
        return Future<FaceAlbumUpdateFaceResponse, Error> { promise in
            FaceAlbum.updateFace(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAblbumGetFaceDetailOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAblbumGetFaceDetailResponse, Error> {
        return Future<FaceAblbumGetFaceDetailResponse, Error> { promise in
            FaceAlbum.getFaceDetail(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumGetImageDetailOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumGetImageDetailResponse, Error> {
        return Future<FaceAlbumGetImageDetailResponse, Error> { promise in
            FaceAlbum.getImageDetail(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAblumGetAllOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAblumGetAllResponse, Error> {
        return  Future<FaceAblumGetAllResponse, Error> { promise in
            FaceAlbum.getAll(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumGetAlbumDetailOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumGetAlbumDetailResponse, Error> {
        return Future<FaceAlbumGetAlbumDetailResponse, Error> { promise in
            FaceAlbum.getAlbumDetail(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumAddImageOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumAddImageResponse, Error> {
        return Future<FaceAlbumAddImageResponse, Error> { promise in
            FaceAlbum.addImage(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumAddImageAsyncOption {
    public func fetch() -> Future<FaceAlbumAddImageAsyncResponse, Error> {
        return Future<FaceAlbumAddImageAsyncResponse, Error> { promise in
            FaceAlbum.addImageAsync(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumAddImageTaskQueryOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumAddImageTaskQueryResponse, Error> {
        return Future<FaceAlbumAddImageTaskQueryResponse, Error> { promise in
            FaceAlbum.addImageTaskQuery(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumDeleteFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumDeleteFaceResponse, Error> {
        return Future<FaceAlbumDeleteFaceResponse, Error> { promise in
            FaceAlbum.deleteFace(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumGroupFaceOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumGroupFaceResponse, Error> {
        return Future<FaceAlbumGroupFaceResponse, Error> { promise in
            FaceAlbum.groupFace(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

extension FaceAlbumGroupFaceTaskQueryOption: FaceppCombineProtocol {
    public func fetch() -> Future<FaceAlbumGroupFaceTaskQueryResponse, Error> {
        return Future<FaceAlbumGroupFaceTaskQueryResponse, Error> { promise in
            FaceAlbum.groupFaceTaskQuery(option: self) { error, resp in
                guard let response = resp else {
                    return promise(.failure(error!))
                }
                promise(.success(response))
            }
        }
    }
}

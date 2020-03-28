//
//  ContentView.swift
//  SwiftUI+Example
//
//  Created by 姜振华 on 2020/3/23.
//  Copyright © 2020 facepp. All rights reserved.
//

import SwiftUI
import Combine
import Foundation
import FaceppSwift

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    
    private var cancellable: AnyCancellable?
    
    var operation: AnyCancellable?
    
    init(url: URL) {
        self.url = url
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
        
        let option = FaceDetectOption()
        option.imageURL = url
        operation = option.fetch()
            .sink(receiveCompletion: { error in
           print(error)
        }) { resp in
            print(resp)
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct AsyncImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Placeholder?
    
    init(url: URL, placeholder: Placeholder? = nil) {
        loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
}

struct ContentView: View {
    let url = URL(string: "http://6shitu.com/wp-content/uploads/2019/11/IMG_3170.jpg")!
    
    var body: some View {
        AsyncImage(
            url: url,
            placeholder: Text("Loading ...")
        ).aspectRatio(contentMode: .fit)
    }
}

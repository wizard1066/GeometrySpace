//
//  ContentView.swift
//  GeometrySpace
//
//  Created by localadmin on 29.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import CoreServices

struct ContentView: View {
  @State private var rect:[CGRect] = []
  @State private var textText = ["","","","","","","","","","","","","","","","","","","","","",""]
  @State private var textID = 0
  @State private var textValue1:String = "Hello World 1"
  @State private var textValue2:String = "Hello World 2"
  @State private var show = false
  @State private var index = 0
//  @State private var index = 0
  var body: some View {
    let dropDelegate = TheDropDelegate(textID: $textID, textText: $textText, rect: $rect)
    return VStack {
    Spacer()
      Text(textValue1)
        .onDrag {
            return NSItemProvider(object: self.textValue1 as NSItemProviderWriting) }
      Text(textValue2)
        .onDrag {
            return NSItemProvider(object: self.textValue2 as NSItemProviderWriting) }
    Spacer()
    VStack(alignment: .center, spacing: 5) {
            ForEach((0 ..< 3).reversed(), id: \.self) { row in
                HStack(alignment: .center, spacing: 5) {
                    ForEach((0 ..< 3).reversed(), id: \.self) { column in
                      Text(self.textText[column + (row*3)])
                      .frame(width: 128, height: 32, alignment: .center)
                      .background(InsideView(rect: self.$rect))
                      .background(Color.yellow)
                      .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
                      .onAppear {
                        DispatchQueue.main.async {
                          self.index = self.index + 1
                        }
                      }
                    }
                }
            }
        }
    
//    VStack {
//      HStack {
//        ForEach((0...3).reversed(), id: \.self) {
//          Text(self.textText[$0])
//            .frame(width: 128, height: 32, alignment: .center)
//            .background(Color.yellow)
//            .background(InsideView(rect: self.$rect))
//            .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
//          }
//        }
//      HStack {
//        ForEach((0...3).reversed(), id: \.self) {
//          Text(self.textText[$0+4])
//            .frame(width: 128, height: 32, alignment: .center)
//            .background(Color.yellow)
//            .background(InsideView(rect: self.$rect))
//            .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
//          }
//        }
//    }
    Spacer()
    }
  }
}


struct InsideView: View {
  @Binding var rect: [CGRect]
  var body: some View {
    
    return GeometryReader { geometry in
      Circle()
      .fill(Color.red)
      .frame(width: 0, height: 0, alignment: .topLeading)
      .opacity(0.2)
      .onAppear {
        self.rect.append(geometry.frame(in: .global))
        
      }
    }
  }
}



struct TheDropDelegate: DropDelegate {
  @Binding var textID:Int
  @Binding var textText:[String]
  @Binding var rect:[CGRect]
  
  func validateDrop(info: DropInfo) -> Bool {
          return info.hasItemsConforming(to: ["public.utf8-plain-text"])
        }
        
        func dropEntered(info: DropInfo) {
            print("drop entered")
        }
        
        func dropTarget(info: DropInfo) -> Int? {
          for squareno in 0..<rect.count {
            if rect[squareno].contains(info.location) {
              return squareno
            }
          }
          return nil
        }
        
        func performDrop(info: DropInfo) -> Bool {
            textID = dropTarget(info: info)!
            if textID == nil { return false }
            
            if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first {
                item.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { (urlData, error) in
                    DispatchQueue.main.async {
                        if let urlData = urlData as? Data {
                           let text = String(decoding: urlData, as: UTF8.self)
                            self.textText[self.textID] = text
                        }
                    }
                }
                return true
            } else {
                return false
            }

        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            print("drop Updated")
            let item = info.hasItemsConforming(to: ["public.utf8-plain-text"])
            let dp = DropProposal(operation: .move)
//            self.textValue = ""
            return dp
        }
        
        func dropExited(info: DropInfo) {
            print("dropExited")
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

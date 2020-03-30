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
  @State private var rect: CGPoint = CGPoint()
  @State private var textText = ["","","",""]
  @State private var textID = 0
  @State private var textValue:String = "Hello World"
  var body: some View {
    let dropDelegate = TheDropDelegate(textID: $textID, textText: $textText, textValue: $textValue)
    return VStack {
    Spacer()
      Text(textValue).background(InsideView(rect: $rect))
        .onDrag {
            return NSItemProvider(object: self.textValue as NSItemProviderWriting) }
    Spacer()
      HStack {
          Text(textText[0])
            .frame(width: 128, height: 20, alignment: .center)
            .background(Color.yellow)
            .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
          Text(textText[1])
            .frame(width: 128, height: 20, alignment: .center)
            .background(Color.yellow)
            .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
        }
    Spacer()
    }
  }
}


struct InsideView: View {
  @Binding var rect: CGPoint
  var body: some View {
    return GeometryReader { geometry in
      Rectangle()
      .frame(width: 0, height: 0, alignment: .leading)
      .onAppear {
        self.rect = geometry.frame(in: .global).origin
      }
    }
  }
}



struct TheDropDelegate: DropDelegate {
  @Binding var textID:Int
  @Binding var textText:[String]
  @Binding var textValue:String
  
  func validateDrop(info: DropInfo) -> Bool {
          return info.hasItemsConforming(to: ["public.utf8-plain-text"])
        }
        
        func dropEntered(info: DropInfo) {
            print("drop entered")
        }
        
        func dropTarget(info: DropInfo) -> Int {
          if info.location.x > UIScreen.main.bounds.width / 2 {
              return(1)
            } else {
              return(0)
            }
        }
        
        func performDrop(info: DropInfo) -> Bool {
            textID = dropTarget(info: info)
            
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

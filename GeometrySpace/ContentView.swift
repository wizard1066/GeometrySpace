//
//  ContentView.swift
//  GeometrySpace
//
//  Created by localadmin on 29.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import CoreServices
import Combine

let colorPublisher = PassthroughSubject<Color, Never>()

struct Fonts {
    static func futuraCondensedMedium(size:CGFloat) -> Font{
        return Font.custom("Futura-CondensedMedium",size: size)
    }
}

let backgrounds = [Color.red,Color.blue,Color.orange,Color.green]

struct ContentView: View {
  @State private var rect:[CGRect] = []
  @State private var textText = [String](repeating: "", count: 16)
  @State private var textColors = [Color](repeating: Color.clear, count: 16)
  @State private var textID:Int? = 0
  @State private var textValue:[String] = [" 1 "," 2 "," 3 "," 4 "]
  @State private var defaultColor = Color.yellow
  @State private var colorID = 0
  @State private var fuck: Int!
  var body: some View {
    let dropDelegate = TheDropDelegate(textID: $textID, textText: $textText, rect: $rect, textColors: $textColors)
    return VStack {
    Spacer()
      HStack(alignment: .center, spacing: 20) {
      ForEach((0 ..< 4), id: \.self) { column in
        Text(self.textValue[column])
          .font(Fonts.futuraCondensedMedium(size: 64))
          .background(backgrounds[column])
          .cornerRadius(32)
        .onDrag {
            return NSItemProvider(object: self.textValue[column] as NSItemProviderWriting) }
        }
      }
    
    Spacer()
    VStack(alignment: .center, spacing: 5) {
            ForEach((0 ..< 4).reversed(), id: \.self) { row in
                HStack(alignment: .center, spacing: 5) {
                    ForEach((0 ..< 4).reversed(), id: \.self) { column in
                       return VStack {
//                        fuck = (column + (row*4))
                        if self.textColors[fCalc(c: column, r: row)] == Color.clear {
                           Text(self.textText[fCalc(c: column, r: row)])
                          .font(Fonts.futuraCondensedMedium(size:48))
                          .frame(width: 64, height: 64, alignment: .center)
                          .background(InsideView(rect: self.$rect))
                          .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
                        } else {
                          Text(self.textText[fCalc(c: column, r: row)])
                          .onTapGesture {
                            self.textText[fCalc(c: column, r: row)] = ""
                            self.textColors[fCalc(c: column, r: row)] = Color.clear
                          }
                          .font(Fonts.futuraCondensedMedium(size:48))
                          .frame(width: 64, height: 64, alignment: .center)
                          .background(self.textColors[fCalc(c: column, r: row)])
                          .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
                          
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
//    }
    Spacer()
    }
  }
}

func fCalc(c:Int, r:Int) -> Int {
  return (c + (r*4))
}

struct TextView: View {
  @Binding var column: Int
  @Binding var row: Int
  @Binding var dropDelegate: DropDelegate
  @Binding var textText:[String]
  @Binding var rect:[CGRect]
  var body: some View {
    let calc = (column + (row*4))
    return BoxView(text: self.textText[calc])
      .background(InsideView(rect: self.$rect))
      .onDrop(of: ["public.utf8-plain-text"], delegate: dropDelegate)
  }
}

struct BoxView: View {
  @State var text:String
  var body: some View {
    return Text(text)
    .font(Fonts.futuraCondensedMedium(size:48))
    .frame(width: 64, height: 32, alignment: .center)
  }
}

struct InsideView: View {
  @Binding var rect: [CGRect]
  @State var toggle = true
  var body: some View {
    
      return VStack {
        if toggle {
         GeometryReader { geometry in
          Rectangle()
            .fill(Color.yellow)
            .frame(width: 64, height: 64, alignment: .center)
            .opacity(0.5)
            .onAppear {
              self.rect.append(geometry.frame(in: .global))
          }
        }
      }
    }
  }
}


//struct InsideView: View {
//  @Binding var rect: [CGRect]
//  @State var toggle = true
//  var body: some View {
//
//      return VStack {
//        if toggle {
//         GeometryReader { geometry in
//          Rectangle()
//            .fill(Color.yellow)
//            .frame(width: 64, height: 64, alignment: .center)
//            .opacity(0.5)
//            .onAppear {
//              self.rect.append(geometry.frame(in: .global))
//          }.onReceive(colorPublisher) { ( color ) in
//            self.toggle.toggle()
//          }
//        }
//        } else {
//           Rectangle()
//          .fill(Color.red)
//          .frame(width: 64, height: 64, alignment: .center)
//          .opacity(0.5)
//          .onReceive(colorPublisher) { ( color ) in
//            self.toggle.toggle()
//          }
//        }
//      }
//  }
//}



struct TheDropDelegate: DropDelegate {
  @Binding var textID:Int?
  @Binding var textText:[String]
  @Binding var rect:[CGRect]
  @Binding var textColors:[Color]
  
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
            guard let _ = textID else {
              return false
            }
            textID = dropTarget(info: info)!
            print("textID ",textID)
            
            
            if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first {
                item.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { (urlData, error) in
                    DispatchQueue.main.async {
                        if let urlData = urlData as? Data {
                           let text = String(decoding: urlData, as: UTF8.self)
                           self.textText[self.textID!] = text
                           switch text {
                            case " 1 ": self.textColors[self.textID!] = Color.red
                            case " 2 ": self.textColors[self.textID!] = Color.blue
                            case " 3 ": self.textColors[self.textID!] = Color.orange
                            // 4 is the last option
                            default: self.textColors[self.textID!] = Color.green
                           }
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

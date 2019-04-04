//
//  Card.swift
//  ARMultiuser
//
//  Created by BC Holmes on 2019-04-04.
//  Copyright © 2019 Intelliware Development. All rights reserved.
//

import Foundation

@objc class Card : NSObject, NSCoding, Codable {
    
    static var types:[String] = [ "Good", "Bad", "Try" ]
    var text:String
    var type:String
    
    required convenience init?(coder decoder: NSCoder) {
        let text = decoder.decodeObject(forKey: "text") as! String
        let type = decoder.decodeObject(forKey: "type") as! String
        self.init(text:text, type:type)
    }
    
    init(text:String, type:String) {
        self.text = text
        self.type = type
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.text, forKey:"text")
        coder.encode(self.type, forKey: "type")
    }
    
    func isGood() -> Bool {
        return self.text == "Good"
    }
    
    func isBad() -> Bool {
        return self.text == "Bad"
    }
    
    func isTry() -> Bool {
        return self.text == "Try"
    }
}

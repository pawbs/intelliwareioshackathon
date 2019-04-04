//
//  CardDeck.swift
//  ARMultiuser
//
//  Created by BC Holmes on 2019-04-04.
//  Copyright © 2019 Intelliware Development. All rights reserved.
//

import Foundation

class CardDeck : NSObject {
    static let instance = CardDeck()
    
    @objc dynamic var cards:[Card] = [];

    func countFor(_ type:String) -> Int {
        var result:Int = 0
        for card in self.cards {
            if (type == card.type) {
                result += 1
            }
        }
        return result
    }
}

//
//  CardCollectionViewController.swift
//  ARMultiuser
//
//  Created by BC Holmes on 2019-04-04.
//  Copyright © 2019 Intelliware Development. All rights reserved.
//

import UIKit

class CardCollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var observer:NSKeyValueObservation?
    var green:UIColor = UIColor.init(red: 184.0/255.0, green: 237.0/255.0, blue: 191.0/255.0, alpha: 1)
    var blue:UIColor = UIColor.init(red: 164.0/255.0, green: 195.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var red:UIColor = UIColor.init(red: 253.0/255.0, green: 127.0/255.0, blue: 124.0/255.0, alpha: 1.0)

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CardDeck.instance.countFor(Card.types[section]);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observer = CardDeck.instance.observe(\.cards, options: [.old, .new]) { (controller, change) in
            self.cardsChanged()
        }
        let addButton = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addCard(_ :)))
        self.navigationItem.rightBarButtonItem = addButton

    }
    
    @objc func addCard(_ sender:UIBarButtonItem) {
        let card = Card(text:"New Card!", type:"Good");
        CardDeck.instance.cards.append(card);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func cardsChanged() {
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CardCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! CardCollectionViewCell

        let card = CardDeck.instance.findCard(indexPath.row, type:Card.types[indexPath.section]);
        cell.textLabel.text = card!.text
        if (indexPath.section == 1) {
            cell.backgroundColor = red
        } else if (indexPath.section == 0) {
            cell.backgroundColor = green
        } else {
            cell.backgroundColor = blue
        }
        return cell;
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.collectionView.bounds.size.width - 42.0) / 2.0;
        return CGSize(width: width, height: width);
    }
}

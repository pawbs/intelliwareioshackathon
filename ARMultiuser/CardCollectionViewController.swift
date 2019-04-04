//
//  CardCollectionViewController.swift
//  ARMultiuser
//
//  Created by BC Holmes on 2019-04-04.
//  Copyright © 2019 Intelliware Development. All rights reserved.
//

import UIKit

class CardCollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CardCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! CardCollectionViewCell
        cell.textLabel.text = "My item"
        if (indexPath.section == 2) {
            cell.backgroundColor = UIColor.init(red: 253.0/255.0, green: 127.0/255.0, blue: 124.0/255.0, alpha: 1.0)
        } else if (indexPath.section == 1) {
            cell.backgroundColor = UIColor.init(red: 164.0/255.0, green: 195.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.init(red: 254.0/255.0, green: 216.0/255.0, blue: 111.0/255.0, alpha: 1.0)
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

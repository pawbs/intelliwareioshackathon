//
//  CardCollectionViewController.swift
//  ARMultiuser
//
//  Created by BC Holmes on 2019-04-04.
//  Copyright © 2019 Intelliware Development. All rights reserved.
//

import UIKit

class CardCollectionViewController : UICollectionViewController {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.collectionView.bounds.size.width / 2.0;
        return CGSize(width: width, height: width);
    }
}

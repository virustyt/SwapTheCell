//
//  CellsVCFlowLayout.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 17/4/2022.
//

import UIKit

class CellsVCFlowLayout : UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
            layoutAttributesObjects?.forEach({ layoutAttributes in
                if layoutAttributes.representedElementCategory == .cell,
                   let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                        layoutAttributes.frame = newFrame
                }
            })
            return layoutAttributesObjects
        }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView,
              let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        else { return nil }

        layoutAttributes.frame.origin.x = sectionInset.left + Consts.minInterItemSpacing
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - Consts.minInterItemSpacing * 2 - sectionInset.left - sectionInset.right
        return layoutAttributes
    }
}

//
//  CollectionViewHitsWidget.swift
//  InstantSearchCore
//
//  Created by Vladislav Fitc on 21/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

open class CollectionViewHitsDataSource<DataSource: HitsDataSource>: NSObject, UICollectionViewDataSource {
  
  var cellConfigurator: HitViewConfigurator<DataSource.Hit, UICollectionViewCell>
  weak var dataSource: DataSource?
  
  init(cellConfigurator: @escaping HitViewConfigurator<DataSource.Hit, UICollectionViewCell>) {
    self.cellConfigurator = cellConfigurator
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource?.numberOfRows() ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let hit = dataSource?.hitForRow(atIndex: indexPath.row) else {
      return UICollectionViewCell()
    }
    return cellConfigurator(hit)
  }
  
}

open class HitsCollectionViewDelegate<DataSource: HitsDataSource>: NSObject, UICollectionViewDelegate {
  
  var clickHandler: HitClickHandler<DataSource.Hit>
  weak var dataSource: DataSource?
  
  init(clickHandler: @escaping HitClickHandler<DataSource.Hit>) {
    self.clickHandler = clickHandler
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let hit = dataSource?.hitForRow(atIndex: indexPath.row) else {
      return
    }
    clickHandler(hit)
  }

}

public class CollectionViewHitsWidget<Hit: Codable>: NSObject, HitsWidget {
  
  public typealias ViewModel = HitsViewModel<Hit>
  public typealias SingleHitView = UICollectionViewCell
  
  public let collectionView: UICollectionView
  
  public weak var viewModel: ViewModel?

  private var dataSource: CollectionViewHitsDataSource<ViewModel>? {
    didSet {
      dataSource?.dataSource = viewModel
      collectionView.dataSource = dataSource
    }
  }
  
  private var delegate: HitsCollectionViewDelegate<ViewModel>? {
    didSet {
      delegate?.dataSource = viewModel
      collectionView.delegate = delegate
    }
  }
  
  public init(collectionView: UICollectionView) {
    self.collectionView = collectionView
  }
  
  public func reload() {
    collectionView.reloadData()
  }
  
  public func scrollToTop() {
    collectionView.scrollToItem(at: IndexPath(), at: .top, animated: false)
  }
  
}

public typealias HitsCollectionViewController<Hit: Codable> = HitsController<CollectionViewHitsWidget<Hit>>

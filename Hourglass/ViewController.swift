//
//  ViewController.swift
//  TimeBudget
//
//  Created by Wojciech Czekalski on 05.08.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Cocoa
import RealmSwift
import ReactiveCocoa

class ViewController: NSViewController {

    @IBOutlet var collectionView: NSCollectionView?
    
    lazy var store: Store = Store(realm: try! Realm(), sideEffect: sideEffects(app: self))
    lazy var delegate: CollectionViewDelegate = CollectionViewDelegate(getDispatch: { [weak self] () -> Dispatch in
        guard let existingSelf = self else {
            return { _ in }
        }
        return existingSelf.store.dispatch
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionView = self.collectionView!
        collectionView.isSelectable = true
        collectionView.delegate = delegate
        collectionView.dataSource = store.dataSource
        collectionView.collectionViewLayout = NSCollectionViewFlowLayout()
        configureReusableCellsOf(collectionView: collectionView)
    }
    
    override func deleteBackward(_ sender: AnyObject?) {
        if let selectedTask = store.state.selectedTask {
            store.dispatch(action: .RemoveTask(task: selectedTask))
        }
    }
}

class CollectionViewDelegate: NSObject, NSCollectionViewDelegateFlowLayout {
    
    let getDispatch: () -> Dispatch
    
    init(getDispatch: () -> Dispatch) {
        self.getDispatch = getDispatch
        super.init()
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return cellSize(in: collectionView)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        self.getDispatch()(action: .Select(indexPath: indexPath))
    }
}

func cellSize(in view: NSView) -> NSSize {
    let itemHeight: CGFloat = 70
    return NSSize(width: view.bounds.size.width, height: itemHeight)
}

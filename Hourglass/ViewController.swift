//
//  ViewController.swift
//  TimeBudget
//
//  Created by Wojciech Czekalski on 05.08.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Cocoa
import RealmSwift

class ViewController: NSViewController {

    @IBOutlet var collectionView: NSCollectionView?
    
    let realm = try! Realm()
    lazy var store: Store = Store(sideEffect: sideEffects(self))
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
        configureReusableCellsOf(collectionView)
    }
    
    override func deleteBackward(_ sender: Any?) {
        if let selectedTask = store.state.selectedTask {
            store.dispatch(.removeTask(task: selectedTask))
        }
    }
}

class CollectionViewDelegate: NSObject, NSCollectionViewDelegateFlowLayout {
    
    let getDispatch: () -> Dispatch
    
    init(getDispatch: @escaping () -> Dispatch) {
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
        self.getDispatch()(.select(indexPath: indexPath))
    }
}

func cellSize(in view: NSView) -> NSSize {
    let itemHeight: CGFloat = 70
    return NSSize(width: view.bounds.size.width, height: itemHeight)
}

//
//  MultipleAssetPickerController.swift
//
//  Created by Lacy Rhoades on 10/17/17.
//

import UIKit

public typealias ProgressAction = (_: Float) -> ()
public typealias FinishedAction = (_: [Asset]) -> ()

public enum MultipleAssetPickerAssetType {
    case file
    case image
    case folder
}

public struct MultipleAssetPickerAsset {
    var name: String
    var path: String
    var type: MultipleAssetPickerAssetType
    public init(name: String, path: String, type: MultipleAssetPickerAssetType) {
        self.name = name
        self.path = path
        self.type = type
    }
}

public struct NavigationItem {
    var title: String
    var path: String?
    
    public init(title: String) {
        self.title = title
    }
}

public protocol MultipleAssetPickerDelegate: class {
    var sourceType: MultipleAssetRowSourceTypes { get set }
    func loadAssets(atPath: String?)
    var preAssetChangeAction: (() -> ())? { get set }
    var assetChangeAction: (() -> ())? { get set }
    var numberOfAssets: Int { get }
    func asset(atIndex: Int) -> MultipleAssetPickerAsset?
    func selectedAssets(forPaths: [String], withProgress: @escaping ProgressAction, andThen: @escaping FinishedAction)
    func canSelect(at: Int) -> Bool
    var loadingText: String { get }
    var navigationItems: [NavigationItem] { get }
}

class MultipleAssetPickerController: UIViewController {
    var sourceType: MultipleAssetRowSourceTypes!
    weak var assetDelegate: MultipleAssetPickerDelegate?
    
    var titleLabel = UILabel()
    var navigationStackView = UIStackView()
    var collectionView: UICollectionView!
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingLabel = UILabel()
    
    var selections: [Int] = []
    
    func getSelectedAssets(withProgress: @escaping ProgressAction, andThen: @escaping FinishedAction) {
        guard let assetDelegate = assetDelegate else {
            return andThen([])
        }
        
        assetDelegate.selectedAssets(forPaths: self.selections.filter({ (eachRow) -> Bool in
            return assetDelegate.asset(atIndex: eachRow) != nil
        }).map({ (eachRow) -> String in
            return assetDelegate.asset(atIndex: eachRow)!.path
        }), withProgress: withProgress, andThen: andThen)
    }
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(MultipleAssetPickerCell.self, forCellWithReuseIdentifier: MultipleAssetPickerCell.cellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.assetDelegate?.sourceType = self.sourceType
        self.assetDelegate?.preAssetChangeAction = {
            self.showLoading()
            self.collectionView.reloadData()
        }
        self.assetDelegate?.assetChangeAction = {
            self.hideLoading()
            self.collectionView.reloadData()
            self.refreshNavigationItems()
        }
        self.assetDelegate?.loadAssets(atPath: nil)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 44.0)
        titleLabel.text = self.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationStackView)
        
        activitySpinner.color = .gray
        activitySpinner.hidesWhenStopped = true
        activitySpinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activitySpinner)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activitySpinner, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activitySpinner, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
        self.loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingLabel.font = UIFont.systemFont(ofSize: 26.0)
        self.view.addSubview(self.loadingLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: loadingLabel, attribute: .bottom, relatedBy: .equal, toItem: activitySpinner, attribute: .top, multiplier: 1, constant: -1 * 12.0)
        ])
        
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0.0))
        
        let matchWidth = NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
        matchWidth.priority = UILayoutPriority.defaultLow
        self.view.addConstraint(matchWidth)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: navigationStackView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0)
        ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.titleLabel.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0),
                navigationStackView.topAnchor.constraintEqualToSystemSpacingBelow(self.titleLabel.bottomAnchor, multiplier: 1.0),
              collectionView.topAnchor.constraintEqualToSystemSpacingBelow(self.navigationStackView.bottomAnchor, multiplier: 1.0),
              guide.bottomAnchor.constraintEqualToSystemSpacingBelow(self.collectionView.bottomAnchor, multiplier: 1.0)
            ])
        } else {
            let space: CGFloat = 8.0
            NSLayoutConstraint.activate([
                self.titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: space),
                self.navigationStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: space),
                self.collectionView.topAnchor.constraint(equalTo: navigationStackView.bottomAnchor, constant: space),
                bottomLayoutGuide.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: space)
            ])
        }
        
        self.showLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = self.selections.isEmpty == false
    }
    
    func showLoading() {
        self.loadingLabel.text = self.assetDelegate?.loadingText
        self.loadingLabel.isHidden = false
        self.activitySpinner.startAnimating()
    }
    
    func hideLoading() {
        self.loadingLabel.isHidden = true
        self.activitySpinner.stopAnimating()
    }
    
    func refreshNavigationItems() {
        self.navigationStackView.arrangedSubviews.forEach { (eachView) in
            self.navigationStackView.removeArrangedSubview(eachView)
        }
        
        for item in self.assetDelegate?.navigationItems ?? [] {
            let button = UIButton()
            button.setTitle(item.title, for: .normal)
            self.navigationStackView.addArrangedSubview(button)
        }
    }
}

extension MultipleAssetPickerController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width, height: 56.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let asset = self.assetDelegate?.asset(atIndex: indexPath.row) {
            if asset.type == .folder {
                self.assetDelegate?.loadAssets(atPath: asset.path)
                self.select(nil)
            } else {
                if self.selections.contains(indexPath.row) {
                    collectionView.deselectItem(at: indexPath, animated: true)
                } else {
                    self.select(indexPath.row)
                }
            }
        }
    }
    
    func select(_ row: Int?) {
        if let row = row, self.selections.contains(row) == false {
            self.selections.append(row)
        } else {
            self.selections = []
        }
        
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = self.selections.isEmpty == false
    }
    
    func deSelect(_ row: Int) {
        if let index = self.selections.index(of: row) {
            self.selections.remove(at: index)
        }
        
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = self.selections.isEmpty == false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if self.selections.contains(indexPath.row) {
            self.deSelect(indexPath.row)
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let assetDelegate = self.assetDelegate {
            return assetDelegate.canSelect(at: indexPath.row)
        } else {
            return true
        }
    }
}

extension MultipleAssetPickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetDelegate?.numberOfAssets ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleAssetPickerCell.cellReuseIdentifier, for: indexPath)
        if let pickerCell = cell as? MultipleAssetPickerCell {
            pickerCell.asset = self.assetDelegate?.asset(atIndex: indexPath.row)
        }
        return cell
    }
}

//
//  MultipleAssetPickerController.swift
//
//  Created by Lacy Rhoades on 10/17/17.
//

import UIKit

public struct FetchProgress {
    public var soFar: Int
    public var total: Int
    
    public init(total: Int) {
        self.total = total
        self.soFar = 0
    }
}
public typealias ProgressAction = (_: FetchProgress) -> ()
public typealias FinishedAction = (_: [Asset]) -> ()

class NavigationButton: UIButton {
    var path: String?
}

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
    
    public init(title: String, path: String) {
        self.title = title
        self.path = path
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
    func fetchProgressText(forProgress: FetchProgress) -> String
    var navigationItems: [NavigationItem] { get }
    func navigate(toPath: String?)
}

class MultipleAssetPickerController: UIViewController {
    var sourceType: MultipleAssetRowSourceTypes!
    weak var assetDelegate: MultipleAssetPickerDelegate?
    
    var stackView = UIStackView()
    
    var titleLabel = UILabel()
    var navigationStackView = UIStackView()
    var collectionView: UICollectionView!
    var grayoutView = UIView()
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingLabel = UILabel()
    var toolbar = UIStackView()
    var selectAllButton = UIButton(type: .custom)
    
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
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
        ])
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 44.0)
        titleLabel.text = self.title
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        
        navigationStackView.axis = .horizontal
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(navigationStackView)
        
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
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(collectionView)
        
        toolbar.axis = .horizontal
        toolbar.distribution = .fillEqually
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(toolbar)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40.0)
        ])
        
        toolbar.addArrangedSubview(UIView())
        toolbar.addArrangedSubview(UIView())
        selectAllButton.setTitle("Select all", for: .normal)
        selectAllButton.setTitle("Clear selection", for: .selected)
        selectAllButton.setTitleColor(UIColor.linkBlue, for: .normal)
        selectAllButton.addTarget(self, action: #selector(didTapSelectAll(_:)), for: .touchUpInside)
        toolbar.addArrangedSubview(selectAllButton)
        
        self.grayoutView.isHidden = true
        self.grayoutView.backgroundColor = .white
        self.grayoutView.alpha = 0.8
        self.grayoutView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.grayoutView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: grayoutView, attribute: .leading, relatedBy: .equal, toItem: collectionView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: grayoutView, attribute: .trailing, relatedBy: .equal, toItem: collectionView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: grayoutView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: grayoutView, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        activitySpinner.color = .gray
        activitySpinner.hidesWhenStopped = true
        activitySpinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activitySpinner)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activitySpinner, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activitySpinner, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = UIFont.systemFont(ofSize: 26.0)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: loadingLabel, attribute: .bottom, relatedBy: .equal, toItem: activitySpinner, attribute: .top, multiplier: 1, constant: -1 * 12.0)
        ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.stackView.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0),                guide.bottomAnchor.constraintEqualToSystemSpacingBelow(self.stackView.bottomAnchor, multiplier: 1.0)
            ])
        } else {
            let space: CGFloat = 8.0
            NSLayoutConstraint.activate([
                self.stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: space),
                bottomLayoutGuide.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: space)
            ])
        }
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56.0),
            NSLayoutConstraint(item: navigationStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 36.0)
        ])
        
        self.showLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateSelectionUI()
        self.assetDelegate?.loadAssets(atPath: nil)
    }
    
    func showFetched(progress: FetchProgress) {
        let text = self.assetDelegate?.fetchProgressText(forProgress: progress)
        DispatchQueue.main.async {
            self.grayoutView.isHidden = false
            self.loadingLabel.text = text
            self.loadingLabel.isHidden = false
            self.activitySpinner.startAnimating()
        }
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
        DispatchQueue.main.async {
            self.navigationStackView.arrangedSubviews.forEach { (eachView) in
                self.navigationStackView.removeArrangedSubview(eachView)
            }
            
            let firstView = UIView()
            firstView.translatesAutoresizingMaskIntoConstraints = false
            let lastView = UIView()
            lastView.translatesAutoresizingMaskIntoConstraints = false
            
            self.navigationStackView.addArrangedSubview(firstView)
            for item in self.assetDelegate?.navigationItems ?? [] {
                let button = NavigationButton()
                button.path = item.path
                button.addTarget(self, action: #selector(self.didTapNavigationItem(_:)), for: .touchUpInside)
                button.setTitle(item.title, for: .normal)
                button.setTitleColor(UIColor.linkBlue, for: .normal)
                self.navigationStackView.addArrangedSubview(button)
                
                let label = UILabel()
                label.text = "/"
                self.navigationStackView.addArrangedSubview(label)
            }
            self.navigationStackView.addArrangedSubview(lastView)
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: lastView, attribute: .width, multiplier: 1, constant: 0)
            ])
        }
    }
    
    @objc func didTapNavigationItem(_ button: NavigationButton) {
        self.assetDelegate?.navigate(toPath: button.path)
        self.select(nil)
    }
}

extension MultipleAssetPickerController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width, height: 86.0)
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
        
        self.updateSelectionUI()
    }
    
    func deSelect(_ row: Int) {
        if let index = self.selections.index(of: row) {
            self.selections.remove(at: index)
        }
        
        self.updateSelectionUI()
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

extension MultipleAssetPickerController {
    @objc func didTapSelectAll(_ button: UIButton) {
        if button.isSelected {
            self.selections = []
            for row in 0...(self.assetDelegate?.numberOfAssets ?? 0) {
                collectionView.deselectItem(at: IndexPath(row: row, section: 0), animated: true)
            }
        } else {
            for row in 0...(self.assetDelegate?.numberOfAssets ?? 0) {
                if let asset = self.assetDelegate?.asset(atIndex: row) {
                    if asset.type == .image {
                        self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                        self.select(row)
                    }
                }
            }
        }
        
        self.updateSelectionUI()
    }
    
    func updateSelectionUI() {
        self.selectAllButton.isSelected = self.selections.isEmpty == false
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = self.selections.isEmpty == false
    }
}

extension UIColor {
    static var linkBlue: UIColor {
        return UIColor(red: 0.2, green: 0.2, blue: 1.0, alpha: 1.0)
    }
    static var backgroundGray: UIColor {
        return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }
}

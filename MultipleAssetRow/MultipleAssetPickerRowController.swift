//  MultipleAssetPickerRowController.swift

import Eureka
import Foundation

/// Selector Controller used to pick an image
open class MultipleAssetPickerRowController: UIViewController, TypedRowControllerType {
    // for TypedRowControllerType
    public var row: RowOf<Assets>!
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    // for us to know what kind of UI to use
    public var assetSourceType: MultipleAssetRowSourceTypes!
    public weak var assetDelegate: MultipleAssetPickerDelegate?
    
    private let pickerController = MultipleAssetPickerController()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.sourceType = self.assetSourceType
        self.pickerController.assetDelegate = self.assetDelegate
        self.pickerController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pickerController.view)
        self.addChildViewController(self.pickerController)
        self.pickerController.didMove(toParentViewController: self)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pickerView]|", options: [], metrics: [:], views: ["pickerView": self.pickerController.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerView]|", options: [], metrics: [:], views: ["pickerView": self.pickerController.view]))
    }
}

/*
 UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Assets>!
    
    public var assetSourceType: MultipleAssetRowSourceTypes = MultipleAssetRowSourceTypes(.photoLibrary) {
        didSet {
            
        }
    }
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        (row as? ImageRow)?.imageURL = info[UIImagePickerControllerReferenceURL] as? URL
//        row.value = info[UIImagePickerControllerOriginalImage] as? UIImage
        onDismissCallback?(self)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onDismissCallback?(self)
    }
}
*/

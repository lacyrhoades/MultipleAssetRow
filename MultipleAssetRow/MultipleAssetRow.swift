//  MultipleAssetRow.swift

import Eureka
import Foundation

public enum MultipleAssetClearAction {
    case no
    case yes(style: UIAlertActionStyle)
}

protocol MultipleAssetRowProtocol {
    var placeholderImages: [UIImage] { get }
}

open class _MultipleAssetRow<Cell: CellType>: OptionsRow<Cell>, PresenterRowType, MultipleAssetRowProtocol where Cell: BaseCell, Cell.Value == Assets {
    
    public typealias PresenterRow = MultipleAssetPickerRowController

    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?

    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?

    open var clearAction = MultipleAssetClearAction.yes(style: .destructive)
    
    open var placeholderImages: [UIImage] = []
    
    open var availableSourceTypes: [MultipleAssetRowSourceTypes] = []
    open weak var assetDelegate: MultipleAssetPickerDelegate?

    public required init(tag: String?) {
        super.init(tag: tag)

        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback {
            return MultipleAssetPickerRowController()
        }, onDismiss: { [weak self] vc in
            self?.select()
            vc.dismiss(animated: true)
        })

        self.displayValueFor = nil
    }

    func displayMultipleAssetPickerRowController(_ sourceType: MultipleAssetRowSourceTypes) {
        if let presentationMode = presentationMode, !isDisabled, let controller = presentationMode.makeController() {
            controller.row = self
            controller.assetSourceType = sourceType
            controller.assetDelegate = self.assetDelegate
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
        }
    }

  /// Extends `didSelect` method
  /// Selecting the "MultipleAsset" Row cell will open a popup to choose where to source the
  /// asset from, based on the `sourceTypes` configured and the available sources.
  open override func customDidSelect() {
    guard !isDisabled else {
      super.customDidSelect()
      return
    }

    deselect()

    var availableSources: MultipleAssetRowSourceTypes = MultipleAssetRowSourceTypes.All

    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let _ = availableSources.insert(MultipleAssetRowSourceTypes.PhotoLibrary)
    }

    // let the user select the source
    let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .actionSheet)

    guard let tableView = cell.formViewController()?.tableView  else { fatalError() }

    if let popView = sourceActionSheet.popoverPresentationController {
      popView.sourceView = tableView
      popView.sourceRect = tableView.convert(cell.accessoryView?.frame ?? cell.contentView.frame, from: cell)
    }

    for type in self.availableSourceTypes {
        createOptionForAlertController(sourceActionSheet, sourceType: type)
    }

    if case .yes(let style) = clearAction, value != nil {
      let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Clear Photo", comment: ""), style: style) { [weak self] _ in
        self?.value = nil
        self?.updateCell()
      }

      sourceActionSheet.addAction(clearPhotoOption)
    }

    if sourceActionSheet.actions.count == 1 {
      // no sheet?
    } else {
      let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

      sourceActionSheet.addAction(cancelOption)

      if let presentingViewController = cell.formViewController() {
        presentingViewController.present(sourceActionSheet, animated: true)
      }
    }
  }

  /**
   Prepares the pushed row setting its title and completion callback.
   */
  open override func prepare(for segue: UIStoryboardSegue) {
    super.prepare(for: segue)
    guard let rowVC = segue.destination as? PresenterRow else { return }
    rowVC.title = selectorTitle ?? rowVC.title
    rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
    onPresentCallback?(cell.formViewController()!, rowVC)
    rowVC.row = self
  }
}

extension _MultipleAssetRow {
    func createOptionForAlertController(_ alertController: UIAlertController, sourceType: MultipleAssetRowSourceTypes) {

        let option = UIAlertAction(title: sourceType.localizedString, style: .default) { [weak self] _ in
            self?.displayMultipleAssetPickerRowController(sourceType)
        }

        alertController.addAction(option)
    }
}

/// A selector row where the user can pick assets
public final class MultipleAssetRow: _MultipleAssetRow<MultipleAssetCell>, RowType {
  public required init(tag: String?) {
    super.init(tag: tag)
  }
}

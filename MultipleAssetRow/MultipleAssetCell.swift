//  MultipleAssetCell.swift

import Eureka

public final class MultipleAssetCell: PushSelectorCell<Assets> {
    public override func setup() {
        super.setup()
        
        accessoryType = .none
        editingAccessoryView = .none

        accessoryView = UIView()
        editingAccessoryView = accessoryView
    }
    
    public override func update() {
        super.update()
        
        selectionStyle = row.isDisabled ? .none : .default
//        (accessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
//        (editingAccessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
    }
}

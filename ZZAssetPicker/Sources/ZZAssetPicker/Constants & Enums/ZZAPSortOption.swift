//
//  ZZAPSortOption.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

@objc public enum ZZAPSortOption: Int, ZZAPLocalizable {
    case creationDateAscending
    case creationDateDescending
    
    public var localizationKey: String {
        switch self {
        case .creationDateAscending:
            return "zzap_sort_creation_date_asc"
        case .creationDateDescending:
            return "zzap_sort_creation_date_desc"
        }
    }
}

extension ZZAPSortOption {
    public var photoKitSortKey: String {
        switch self {
        case .creationDateAscending, .creationDateDescending:
            return "creationDate"
        }
    }
    
    public var isAscending: Bool {
        switch self {
        case .creationDateAscending:
            return true
        case .creationDateDescending:
            return false
        }
    }
}

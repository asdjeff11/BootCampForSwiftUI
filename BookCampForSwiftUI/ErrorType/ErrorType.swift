//
//  ErrorType.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/4.
//
import Foundation

enum AppError: Error, LocalizedError {
    case dataLoadError(underlyingError: Error)
    case databaseError(error: MyDataBaseActor.SQLiteError)
    case unknownError(error: Error)

    var errorDescription: String? {
        switch self {
        case .dataLoadError(let underlyingError):
            return "Loading failed: \(underlyingError.localizedDescription)"
        case .databaseError(let error):
            return error.localizedDescription
        case .unknownError(let error) :
            return error.localizedDescription
        }
    }
}

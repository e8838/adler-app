import SwiftUI

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income, expense
    var id: String { rawValue }
    var title: String { self == .income ? "Ingreso" : "Egreso" }
}

struct Transaction: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: TransactionType
    var amount: Double
    var title: String
    var category: String
    var date: Date
}

enum Categories {
    static func list(for type: TransactionType) -> [String] {
        switch type {
        case .income: return ["Salario", "Ventas", "Regalo", "Otros"]
        case .expense: return ["Comida", "Transporte", "Hogar", "Ocio", "Salud", "Compras", "Otros"]
        }
    }
}

enum Theme {
    static let background = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let card = Color(red: 0.09, green: 0.10, blue: 0.15)
    static let income = Color(red: 0.22, green: 0.86, blue: 0.55)
    static let expense = Color(red: 1.00, green: 0.35, blue: 0.42)
    static let accent = Color(red: 0.45, green: 0.55, blue: 1.00)
    static let muted = Color(red: 0.55, green: 0.58, blue: 0.68)
}

let currencyCode: String = Locale.current.currency?.identifier ?? "USD"

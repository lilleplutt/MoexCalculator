import Foundation

// Тип Currency определяет коды четырёх валют: рубля, юаня, евро и доллара США.
// Используется везде, где требуется работа с валютами.
// Реализует протокол Identifiable, чтобы в SwiftUI работал селектор кода валюты.
enum Currency: String, CaseIterable, Identifiable {
    
    // Коды валют
    case RUB
    case CNY
    case EUR
    case USD
    
    // Свойство ID нужно для реализации протокола Identifiable.
    // Оно определяет уникальный идентификатор объекта этого типа.
    // Здесь Self означает ID типа Currency, а self — одно из значений кода валют.
    // То есть идентификатор ID принимает одно из значений: RUB, CNY, EUR, или USD.
    var id: Self { self }
    
    // Эмоджи с флагами стран-эмитентов
    var flag: String {
        switch self {
        case .RUB: return "🇷🇺"
        case .CNY: return "🇨🇳"
        case .EUR: return "🇪🇺"
        case .USD: return "🇺🇸"
        }
    }
}

// Тип для хранения валютных курсов
typealias CurrencyRates = [Currency: Double]

// Тип, который используется для конвертации валют
struct CurrencyAmount {
    let currency: Currency
    let amount: Double
}

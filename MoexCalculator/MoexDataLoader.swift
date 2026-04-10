import Combine
import Foundation

final class MoexDataLoader {
    
    private static let endpoint = URL(string: "http://iss.moex.com/iss/statistics/engines/currency/markets/selt/rates.json?iss.meta=off")!
    
    func fetch(_ endpoint: URL = endpoint) -> AnyPublisher<CurrencyRates, Error> {
        
        URLSession.shared.dataTaskPublisher(for: endpoint)
            .map { $0.data }
            .decode(type: MoexQuote.self, decoder: JSONDecoder())
            .map { $0.currencyRates }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

struct MoexQuote: Decodable {
    let wap_rates: RawQuotes
    let cbrf: RawQuotes?
}

extension MoexQuote {
    
    var currencyRates: CurrencyRates {
        
        var result: CurrencyRates = [.RUB: 1.0]
        
        guard
            let currencyNameIndex = wap_rates.columns.map ({ $0.lowercased() }).firstIndex(of: "shortname"),
            let priceIndex = wap_rates.columns.map ({ $0.lowercased() }).firstIndex(of: "price")
        else { return result }
        
        wap_rates.data.forEach { quoteArray in
            
            guard
                quoteArray.indices.contains(currencyNameIndex),
                quoteArray.indices.contains(priceIndex),
                let rate = Double(quoteArray[priceIndex]),
                let currency = Currency(rawValue: String(quoteArray[currencyNameIndex].prefix(3)).uppercased())
            else { return }
            
            result[currency] = rate
        }

        // На MOEX в таблице wap_rates часто остаются только CNY/RUB (и иногда USD/RUB),
        // поэтому как запасной источник берем официальные курсы ЦБ из блока cbrf.
        if let cbrf = cbrf {
            if let usd = cbrf.value(named: "cbrf_usd_last") {
                result[.USD] = usd
            }
            if let eur = cbrf.value(named: "cbrf_eur_last") {
                result[.EUR] = eur
            }
        }
        
        return result
    }
}

struct RawQuotes: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case columns, data
    }
    
    let columns: [String]
    let data: [[String]]
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columns = try container.decode([String].self, forKey: .columns)
        
        var result = [[String]]()
        var arraysContainer = try container.nestedUnkeyedContainer(forKey: .data)
        
        while !arraysContainer.isAtEnd {
            var singleArrayContainer = try arraysContainer.nestedUnkeyedContainer()
            let array = singleArrayContainer.decode(fromArray: &singleArrayContainer)
            result.append(array)
        }
        
        data = result
    }
}

extension RawQuotes {
    
    func value(named column: String) -> Double? {
        guard
            let index = columns.map({ $0.lowercased() }).firstIndex(of: column.lowercased()),
            let firstRow = data.first,
            firstRow.indices.contains(index),
            let value = Double(firstRow[index])
        else { return nil }
        
        return value
    }
}

extension UnkeyedDecodingContainer {
    
    func decode(fromArray container: inout UnkeyedDecodingContainer) -> [String] {
        
        var result = [String]()
        while !container.isAtEnd {
            
            if let value = try? container.decode(String.self) {
                result.append(value)
            } else if let value = try? container.decode(Int.self) {
                result.append("\(value)")
            } else if let value = try? container.decode(Double.self) {
                result.append("\(value)")
            }
        }
        return result
    }
}

//
//  ContentView.swift
//  CountryClaudeAsync
//
//  Created by Tatiana Kornilova on 01.11.2024.
//

// ContentView.swift
//  CountryClaude
//
//  Created by Tatiana Kornilova on 01.11.2024.
//


import SwiftUI

/*
// Models
import Foundation

struct Metadata: Decodable {
    let page: Int
    let pages: Int
    let perPage: String
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "per_page"
        case total
    }
}

struct Region: Decodable {
    let id: String
    let iso2code: String
    let value: String
}

struct AdminRegion: Decodable {
    let id: String
    let iso2code: String
    let value: String
}

struct IncomeLevel: Decodable {
    let id: String
    let iso2code: String
    let value: String
}

struct LendingType: Decodable {
    let id: String
    let iso2code: String
    let value: String
}

struct Country: Decodable, Identifiable {
    let id: String
    let iso2Code: String
    let name: String
    let region: Region
    let adminregion: AdminRegion
    let incomeLevel: IncomeLevel
    let lendingType: LendingType
    let capitalCity: String
    let longitude: String
    let latitude: String
    
}

struct Response: Decodable {
    let metadata: Metadata
    let countries: [Country]
}

extension Response {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.metadata = try container.decode(Metadata.self)
        self.countries = try container.decode([Country].self)
    }
}
//----------------
struct CountryApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let flag: String
    var population: Int?
    var gdp: Double?
    let iso2Code: String
}
// -----------Indicator----------
struct WorldBankResponse<T: Decodable>: Decodable {
    let metadata: MetadataIndicator
    let data: [T]
    
    // Custom initializer to handle the nested array structure
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.metadata = try container.decode(MetadataIndicator.self)
        self.data = try container.decode([T].self)
    }
}

// Model for Metadata
struct MetadataIndicator: Decodable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "per_page"
        case total
    }
}

// Model for Indicator
struct Indicator: Decodable {
    let id: String
    let value: String
}

// Model for Country
struct CountryIndicator: Decodable {
    let id: String
    let value: String
}

// Model for Population Data
struct PopulationData: Decodable {
    let indicator: Indicator
    let country: CountryIndicator
    let countryIso3Code: String
    let date: String
    let value: Int?
    let unit: String
    let obsStatus: String
    let decimal: Int
    
    enum CodingKeys: String, CodingKey {
        case indicator
        case country
        case countryIso3Code = "countryiso3code"
        case date
        case value
        case unit
        case obsStatus = "obs_status"
        case decimal
    }
}

// Model for GDP Data
struct GDPData: Decodable {
    let indicator: Indicator
    let country: CountryIndicator
    let countryIso3Code: String
    let date: String
    let value: Double?
    let unit: String
    let obsStatus: String
    let decimal: Int
    
    enum CodingKeys: String, CodingKey {
        case indicator
        case country
        case countryIso3Code = "countryiso3code"
        case date
        case value
        case unit
        case obsStatus = "obs_status"
        case decimal
    }
}*/
// Models
struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let flag: String
    var population: Int?
    var gdp: Double?
    let iso2Code: String
}

// Exact World Bank API response format
//----- Root
struct WorldBankResponse: Decodable {
    let metadata: WorldBankMetadata
    let countries: [WorldBankCountry]
    
   init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        metadata = try container.decode(WorldBankMetadata.self)
        countries = try container.decode([WorldBankCountry].self)
    }
}

//------- Meta
struct WorldBankMetadata: Decodable {
    let page: Int
    let pages: Int
    let perPage: String
    let total: Int
    
    enum CodingKeys: String, CodingKey {
            case page
            case pages
            case perPage = "per_page"
            case total
        }
}

//------- Country
struct WorldBankCountry: Decodable {
    let id: String
    let iso2Code: String
    let name: String
    let region: Region
    let adminregion: AdminRegion
    let incomeLevel: IncomeLevel
    let lendingType: LendingType
    let capitalCity: String
    let longitude: String
    let latitude: String
    
    struct Region: Decodable {
        let id: String
        let iso2code: String
        let value: String
    }
    
    struct AdminRegion: Decodable {
        let id: String
        let iso2code: String
        let value: String
    }
    
    struct IncomeLevel: Decodable {
        let id: String
        let iso2code: String
        let value: String
    }
    
    struct LendingType: Decodable {
        let id: String
        let iso2code: String
        let value: String
    }
}
//----- Root
struct IndicatorResponse: Decodable {
    let metadata: IndicatorMetadata
    let data: [IndicatorData]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        metadata = try container.decode(IndicatorMetadata.self)
        data = try container.decode([IndicatorData].self)
    }
}

//----- Meta
struct IndicatorMetadata: Decodable {
    let page: Int
    let pages: Int
    let per_page: Int
    let total: Int
}

//----- Indicator
struct IndicatorData: Decodable {
    let value: Double?
    let date: String
}

@MainActor
class CountriesViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.worldbank.org/v2"
    
    // MARK: - Load Countries
    func loadCountries() async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/country?format=json&per_page=300"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WorldBankResponse.self, from: data)
            let fetchedCountries = response.countries
            
            // Filter and map countries
            let filteredCountries = fetchedCountries
                .filter { $0.region.value != "Aggregates" }
                .map { countryData in
                    Country(
                        name: countryData.name,
                        category: countryData.region.value,
                        flag: self.flagEmoji(from: countryData.iso2Code),
                        population: nil,
                        gdp: nil,
                        iso2Code: countryData.iso2Code
                    )
                }
            
            countries = filteredCountries
            isLoading = false
            
            // Fetch additional data concurrently
            await fetchAdditionalData(for: filteredCountries)
        } catch {
            errorMessage = "Failed to load countries: \(error.localizedDescription)"
            print("Error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Additional Data
    private func fetchAdditionalData(for countries: [Country]) async {
        await withTaskGroup(of: Void.self) { group in
            for country in countries {
                group.addTask { await self.fetchPopulation(for: country) }
                group.addTask { await self.fetchGDP(for: country) }
            }
        }
    }
    
    // MARK: - Fetch Population
    private func fetchPopulation(for country: Country) async {
        let indicator = "SP.POP.TOTL"
        let urlString = "\(baseURL)/country/\(country.iso2Code)/indicator/\(indicator)?format=json&per_page=1&date=2022"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(IndicatorResponse.self, from: data)
            let population = response.data.first?.value.flatMap { Int($0) }
            
            // Update population in the main thread
            if let index = countries.firstIndex(where: { $0.iso2Code == country.iso2Code }) {
                    countries[index].population = population
            }
        } catch {
            print("Failed to fetch population for \(country.iso2Code): \(error)")
        }
    }
    
    // MARK: - Fetch GDP
    private func fetchGDP(for country: Country) async {
        let indicator = "NY.GDP.MKTP.CD"
        let urlString = "\(baseURL)/country/\(country.iso2Code)/indicator/\(indicator)?format=json&per_page=1&date=2022"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(IndicatorResponse.self, from: data)
            let gdp = response.data.first?.value
            
            // Update GDP in the main thread
            if let index = countries.firstIndex(where: { $0.iso2Code == country.iso2Code }) {
                countries[index].gdp = gdp
            }
        } catch {
            print("Failed to fetch GDP for \(country.iso2Code): \(error)")
        }
    }
    
    // MARK: - Flag Emoji
    private func flagEmoji(from iso2Code: String) -> String {
        let base: UInt32 = 127397
        return iso2Code.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value).map(String.init)
        }.joined()
    }
    
    // MARK: - Categories
    var categories: [String] {
        Array(Set(countries.map { $0.category })).sorted()
    }
    
    func countries(in category: String) -> [Country] {
        countries.filter { $0.category == category }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading countries...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage, retryAction: {
                        Task {
                            await viewModel.loadCountries()
                        }
                    })
                } else {
                    CountryListView(viewModel: viewModel)
                }
            }
            .navigationTitle("World Countries")
        }
        .task {
            await viewModel.loadCountries()
               }
    }
}

// Rest of the view code remains the same...
struct CountryListView: View {
    @ObservedObject var viewModel: CountriesViewModel
    
    var body: some View {
       List {
            ForEach(viewModel.categories, id: \.self) { category in
                Section(header: Text(category)) {
                    ForEach(viewModel.countries(in: category)) { country in
                        NavigationLink(destination: CountryDetailView(country: country)) {
                            CountryRowView(country: country)
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadCountries()
        }
    }
}

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack {
            Text(country.flag)
                .font(.title2)
            Text(country.name)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
               Text(country.flag)
                   .font(.system(size: 100))
                
                Text(country.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "Region", value: country.category)
                    
                   if let population = country.population {
                        DetailRow(
                            title: "Population",
                            value: formatNumber1(population)
                        )
                    }
                    
                   if let gdp = country.gdp {
                        DetailRow(
                            title: "GDP (USD)",
                            value: formatCurrency(gdp)
                        )
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
    private func formatNumber1(_ population: Int) -> String {
        let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                
                if population >= 1_000_000_000 {
                    let billions = Double(population) / 1_000_000_000
                    return "\(formatter.string(from: NSNumber(value: billions)) ?? "")B"
                } else if population >= 1_000_000 {
                    let millions = Double(population) / 1_000_000
                    return "\(formatter.string(from: NSNumber(value: millions)) ?? "")M"
                } else if population >= 1_000 {
                    let thousands = Double(population) / 1_000
                    return "\(formatter.string(from: NSNumber(value: thousands)) ?? "")K"
                }
                
                return formatter.string(from: NSNumber(value: population)) ?? "N/A"
    }
    
    private func formatCurrency(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.title)
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry", action: retryAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  SwiftDataFilmPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData

struct SwiftDataFilmPickerView: View {
    // MARK: - Core Data Properties
    let films: [Film]
    @Binding var selectedFilm: Film?
    
    // MARK: - SwiftData Properties
    let swiftDataFilms: [SwiftDataFilm]
    @Binding var selectedSwiftDataFilm: SwiftDataFilm?
    
    // MARK: - Shared Properties
    @Binding var iso: Int32
    let onDismiss: () -> Void
    let onFilmSelected: ((Film) -> Void)?
    let onSwiftDataFilmSelected: ((SwiftDataFilm) -> Void)?
    
    // MARK: - Data Mode
    @Binding var useSwiftData: Bool
    
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    var filteredFilms: [Film] {
        if searchText.isEmpty {
            return films
        } else {
            return films.filter { film in
                let filmName = film.name ?? ""
                let manufacturer = film.manufacturer ?? ""
                let searchQuery = searchText.lowercased()
                
                return filmName.lowercased().contains(searchQuery) ||
                       manufacturer.lowercased().contains(searchQuery)
            }
        }
    }
    
    var filteredSwiftDataFilms: [SwiftDataFilm] {
        if searchText.isEmpty {
            return swiftDataFilms
        } else {
            return swiftDataFilms.filter { film in
                let filmName = film.name
                let manufacturer = film.manufacturer
                let searchQuery = searchText.lowercased()
                
                return filmName.lowercased().contains(searchQuery) ||
                       manufacturer.lowercased().contains(searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Data Mode Toggle
                    HStack {
                        Text("Data Mode:")
                            .font(.headline)
                        Spacer()
                        Button(useSwiftData ? "SwiftData" : "Core Data") {
                            useSwiftData.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if useSwiftData {
                                // SwiftData Films
                                ForEach(filteredSwiftDataFilms) { film in
                                    Button(action: {
                                        selectedSwiftDataFilm = film
                                        iso = Int32(film.defaultISO)
                                        onSwiftDataFilmSelected?(film)
                                        onDismiss()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(film.name)
                                                    .pickerTitleStyle()
                                                
                                                Text("\(film.manufacturer) • \(String(format: String(localized: "isoLabel"), "\(film.defaultISO)"))")
                                                    .pickerSubtitleStyle()
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedSwiftDataFilm?.id == film.id {
                                                Image(systemName: "checkmark")
                                                    .checkmarkStyle()
                                            }
                                        }
                                        .pickerCardStyle()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            } else {
                                // Core Data Films
                                ForEach(filteredFilms) { film in
                                    Button(action: {
                                        selectedFilm = film
                                        iso = Int32(film.defaultISO)
                                        onFilmSelected?(film)
                                        onDismiss()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(film.name ?? "")
                                                    .pickerTitleStyle()
                                                
                                                Text("\(film.manufacturer ?? "") • \(String(format: String(localized: "isoLabel"), "\(film.defaultISO)"))")
                                                    .pickerSubtitleStyle()
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedFilm?.id == film.id {
                                                Image(systemName: "checkmark")
                                                    .checkmarkStyle()
                                            }
                                        }
                                        .pickerCardStyle()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "searchFilms"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("selectFilm"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct SwiftDataFilmPickerView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftDataFilmPickerView(
            films: [],
            selectedFilm: .constant(nil),
            swiftDataFilms: [],
            selectedSwiftDataFilm: .constant(nil),
            iso: .constant(400),
            onDismiss: {},
            onFilmSelected: { _ in },
            onSwiftDataFilmSelected: { _ in },
            useSwiftData: .constant(false)
        )
    }
}

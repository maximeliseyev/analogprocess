//
//  SwiftDataFilmPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct FilmPickerView: View {
    // MARK: - SwiftData Properties
    let films: [SwiftDataFilm]
    @Binding var selectedFilm: SwiftDataFilm?
    @Binding var iso: Int32
    let onDismiss: () -> Void
    let onFilmSelected: ((SwiftDataFilm) -> Void)?
    
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    var filteredFilms: [SwiftDataFilm] {
        if searchText.isEmpty {
            return films
        } else {
            return films.filter { film in
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
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredFilms) { film in
                                Button(action: {
                                    selectedFilm = film
                                    iso = Int32(film.defaultISO)
                                    onFilmSelected?(film)
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

struct FilmPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FilmPickerView(
            films: [],
            selectedFilm: .constant(nil),
            iso: .constant(100),
            onDismiss: {},
            onFilmSelected: nil
        )
    }
}

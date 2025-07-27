//
//  FilmPickerView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct FilmPickerView: View {
    let films: [Film]
    @Binding var selectedFilm: Film?
    @Binding var iso: Int
    let onDismiss: () -> Void
    
    @State private var searchText = ""
    
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredFilms) { film in
                        Button(action: {
                            selectedFilm = film
                            iso = Int(film.defaultISO)
                            onDismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(film.name ?? "")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(film.manufacturer ?? "") • ISO \(film.defaultISO)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedFilm?.id == film.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search films...")
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


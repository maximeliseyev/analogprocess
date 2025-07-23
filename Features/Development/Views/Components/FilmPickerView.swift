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
    
    var body: some View {
        NavigationView {
            List(films) { film in
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
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите пленку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
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
            iso: .constant(400),
            onDismiss: {}
        )
    }
} 
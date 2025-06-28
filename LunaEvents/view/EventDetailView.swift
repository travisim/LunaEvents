//
//  EventDetailView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: LumaEvent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let coverImageURL = event.cover_image, let url = URL(string: coverImageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                }
                
                Text(event.title ?? "No Title")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Date", value: event.date)
                    InfoRow(label: "Time", value: event.time)
                    InfoRow(label: "Location", value: event.location)
                    InfoRow(label: "Organizer", value: event.organizer)
                    InfoRow(label: "Status", value: event.status)
                }
                
                if let linkURL = event.link, let url = URL(string: linkURL) {
                    Link("Join Event", destination: url)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label + ":")
                .fontWeight(.bold)
            Text(value ?? "N/A")
            Spacer()
        }
        .font(.body)
    }
} 
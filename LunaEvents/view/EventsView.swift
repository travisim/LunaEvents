//
//  EventsView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    @State private var selectedEvent: LumaEvent?

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            if !viewModel.recommendedEvents.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("Recommended for You")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal)
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                        ForEach(viewModel.recommendedEvents) { event in
                                            EventCard(event: event, isRecommended: true)
                                                .onTapGesture {
                                                    selectedEvent = event
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                    Text("All Events")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(viewModel.events) { event in
                                        EventCard(event: event, isRecommended: false)
                                            .onTapGesture {
                                                selectedEvent = event
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Events")
            .onAppear {
                viewModel.fetchEvents()
                viewModel.fetchRecommendedEvents()
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
        }
    }
}

struct EventCard: View {
    let event: LumaEvent
    let isRecommended: Bool

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                if let coverImageURL = event.displayCoverImage, let url = URL(string: coverImageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 150)
                }
                
                if isRecommended {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .background(Circle().fill(Color.white))
                        .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(event.displayTitle ?? "No Title")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(event.displayDate ?? "No Date")
                    .font(.subheadline)
                
                Text(event.displayTime ?? "No Time")
                    .font(.caption)
                
                if isRecommended, let similarity = event.similarity {
                    Text("Match: \(Int(similarity * 100))%")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: isRecommended ? 8 : 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRecommended ? Color.yellow : Color.clear, lineWidth: 2)
        )
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}

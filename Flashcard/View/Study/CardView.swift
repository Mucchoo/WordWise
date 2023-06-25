//
//  CardView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import AVFoundation

struct CardView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var showingCardView: Bool
    @State private var isVStackVisible = false
    @State private var isWordVisible = true
    @State private var learningCards: [LearningCard]
    @State private var index = 0
    @State private var isFinished = false
    @State private var isButtonEnabled = true
    @State private var audioPlayer: AVAudioPlayer?
    
    init(showingCardView: Binding<Bool>, cardsToStudy: [Card]) {
        self._showingCardView = showingCardView
        self._learningCards = State(initialValue: cardsToStudy.map { LearningCard(card: $0) })
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 8)
                    .padding()
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height > 50 {
                                    dismiss()
                                }
                            }
                    )
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width , height: geometry.size.height)
                            .opacity(0.2)
                            .foregroundColor(Color(UIColor.tintColor))

                        Rectangle()
                            .frame(width: min(CGFloat(Float(learningCards.filter { !$0.isLearning }.count) / Float(learningCards.count))*geometry.size.width, geometry.size.width), height: 10)
                            .foregroundColor(isFinished ? .green : Color(UIColor.tintColor))
                            .animation(.spring())
                    }
                }
                .cornerRadius(5)
                .frame(height: 10)
                
                ZStack(alignment: .center) {
                    GeometryReader { geometry in
                        VStack {
                            Text("Finished!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                            Text("You've learned \(learningCards.count) cards")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.top)
                        }
                        .scaleEffect(isFinished ? 1 : 0.1)
                        .opacity(isFinished ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    
                    ScrollView {
                        Spacer().frame(height: 20)
                        
                        VStack {
                            Text(learningCards[index].card.text ?? "Unknown")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(learningCards[index].card.phoneticsArray.first?.text ?? "Unknown")
                                .foregroundColor(.primary)
                        }
                        .opacity(isWordVisible ? 1 : 0)
                        .animation(.easeIn(duration: 0.3), value: isWordVisible)
                        .onTapGesture {
                            playAudio(card: learningCards[index].card)
                        }
                        Spacer().frame(height: 20)
                        
                        ZStack {
                            VStack {
                                ForEach(learningCards[index].card.meaningsArray.indices, id: \.self) { idx in
                                    if idx != 0 {
                                        Divider()
                                        Spacer().frame(height: 20)
                                    }
                                    DefinitionDetailView(meaning: learningCards[index].card.meaningsArray[idx], index: idx)
                                }
                            }
                            
                            Rectangle()
                                .fill(Color.white)
                                .opacity(isVStackVisible ? 0 : 1)
                                .animation(.easeIn(duration: 0.3), value: isVStackVisible)
                                .zIndex(1)
                        }
                        
                        Spacer()
                    }.opacity(isFinished ? 0 : 1)
                }
                
                ZStack {
                    Button(action: {
                        showingCardView = false
                    }) {
                        Text("Go to Top Page")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.opacity(isFinished ? 1 : 0)
                    
                    HStack {
                        Button(action: {
                            guard isButtonEnabled else { return }

                            isButtonEnabled = false
                            isVStackVisible = false
                            isWordVisible = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.none) {
                                    let card = learningCards.remove(at: index)
                                    learningCards.append(card)
                                }
                                
                                isButtonEnabled = true
                                isWordVisible = true
                                
                                let card = learningCards[index].card
                                card.failedTimes += 1
                                card.status = 1
                                PersistenceController.shared.saveContext()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    playAudio(card: card)
                                }
                            }
                        }) {
                            Text("Hard")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            guard isButtonEnabled else { return }
                            
                            isButtonEnabled = false
                            isVStackVisible = false
                            isWordVisible = false
                            
                            learningCards[index].isLearning = false
                            learningCards[index].card.status = 0
                            PersistenceController.shared.saveContext()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.none) {
                                    if index + 1 == learningCards.count {
                                        isFinished = true
                                    } else {
                                        index += 1
                                    }
                                }

                                isButtonEnabled = true
                                isWordVisible = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    playAudio(card: learningCards[index].card)
                                }
                            }
                        }) {
                            Text("Easy")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }.opacity(isFinished ? 0 : 1)

                }
            }
        }
        .padding([.leading, .trailing])
        .background(Color.white.ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            isVStackVisible = true
        }
        .onAppear {
            learningCards.forEach { card in
                guard let phonetic = card.card.phoneticsArray.first else { return }
                downloadAudio(phonetic: phonetic)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("play first Audio")
                playAudio(card: learningCards[0].card)
            }
        }
    }
    
    private func playAudio(card: Card) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let urlString = card.phoneticsArray.first?.downloadedAudioUrlString,
                  let url = URL(string: urlString) else {
                print("playAudio blocked")
                playAudio(card: card)
                return
            }
            
            print("playAudio: \(card.text ?? "nil") url: \(urlString)")
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.category != .playback {
                    try audioSession.setCategory(.playback, options: .allowBluetooth)
                    try audioSession.setActive(true)
                }
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.isMeteringEnabled = true
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch {
                print("playAudio failed: \(error.localizedDescription)")
                playAudio(card: card)
            }
        }
    }
    
    private func downloadAudio(phonetic: Phonetic) {
        guard let urlString = phonetic.audio,
              let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else { return }
        
        let downloadTask = URLSession.shared.downloadTask(with: URLRequest(url: url)) { url, response, error in
            guard error == nil, let fileURL = url else { return }
            
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                
                DispatchQueue.main.async {
                    print("downloaded \(phonetic.unwrappedText): \(savedURL.absoluteString)")
                    phonetic.downloadedAudioUrlString = savedURL.absoluteString
                    PersistenceController.shared.saveContext()
                }
            } catch {
                print("failed downloading audio: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }
}

struct DefinitionDetailView: View {
    let meaning: Meaning
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Meaning \(index + 1)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(meaning.partOfSpeech ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                    .padding(.top, 4)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            
            ForEach(meaning.definitionsArray.indices, id: \.self) { index in
                if index != 0 {
                    Spacer().frame(height: 24)
                }
                
                let definition = meaning.definitionsArray[index]
                
                VStack(alignment: .leading) {
                    Text("\(index + 1). \(definition.definition ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                                        
                    if let example = definition.example, !example.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Example: " + example)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let synonyms = definition.synonyms, !synonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Synonyms: " + synonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let antonyms = definition.antonyms, !antonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Antonyms: " + antonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @State static var showingCardView = true

    static var previews: some View {
        CardView(showingCardView: $showingCardView, cardsToStudy: [])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

//
//  ContentView.swift
//  WordScrumble(Project 5)
//
//  Created by mac on 15.08.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0

    
    init() {
        UITableView.appearance().backgroundColor = UIColor(named: "Color")
    }

    var body: some View {
        VStack{
            
            Text(rootWord.uppercased()).foregroundColor(Color("Color-1")).font(.system(size: 50).bold())
            
          List {
              Section {
                  HStack {
                      
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                      
                        Spacer()
                      
                      Button (action: startGame, label: {
                          
                                Image(systemName: "house").foregroundColor(Color("Color"))
                          
                      })
                        
                      
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                        Text("\(word)")
                        Spacer()
                        Image(systemName: "\(word.count).circle")
                        }
                    }
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            
            Text("Score: \(score)").foregroundColor(Color("Color-1")).font(.system(size: 35).bold())
        
        }.background(Color("Color"))
            .preferredColorScheme(.light)
    }

     func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
         guard answer.count > 2 else {
             wordError(title: "Word is too short", message: "It's not that easy!")
             return
         }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Where is no such word or you misspeled it")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        score+=newWord.count*usedWords.count
        newWord = ""
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                score = 0
                usedWords.removeAll()
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


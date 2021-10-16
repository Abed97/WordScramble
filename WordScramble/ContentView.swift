//
//  ContentView.swift
//  WordScramble
//
//  Created by Abed Atassi on 2021-09-14.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
        NavigationView {
            VStack {

                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Score: \(score)")
                    .font(.title)
            }
            .navigationBarTitle(rootWord)
            
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing:
                Button(action: startGame) {
                    Text("New word")
                }
            )
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            showError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isMatching(word: answer) else {
            showError(title: "Word not recognized", message: "You cannot make a word up")
            return
        }
        
        guard isReal(word: answer) else {
            showError(title: "Word not possible", message: "This is not a real word")
            return
        }
        
        score += 2 * (answer.count)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        
        if let txtFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: txtFileURL) {
                
                let words = startWords.components(separatedBy: "\n")
                
                rootWord = words.randomElement() ?? "Lol"
                usedWords = [String]()
                score = 0
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        
        if (word == rootWord) {
            return false
        }
        
        return !usedWords.contains(word)
    }
    
    func isMatching(word: String) -> Bool {
        var temp = rootWord
        
        for letter in word {
            if let pos = temp.firstIndex(of: letter) {
                temp.remove(at: pos)
            } else {
                return false
            }
        }
        return true
        
    }
    
    func isReal(word: String) -> Bool {
        
        if (word.count < 3) {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showError(title: String, message: String) {
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

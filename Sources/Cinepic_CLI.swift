// The Swift Programming Language
// https://docs.swift.org/swift-book
// Google GenerativeAI Gemini
// https://github.com/google/generative-ai-swift
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import GoogleGenerativeAI

let model = GenerativeModel(name: "MODEL_NAME", apiKey: "")

@main
struct Cinepic_CLI: ParsableCommand {
    
    static var configuration = CommandConfiguration(
            commandName: "cinepic",
            abstract: "Cinepic: A Title For Your Academy Saga",
            version: "1.0.0"
    )
    
    @Argument(help: "The phrases to repeat")
    var initialSelected: String
    
    @Argument(help: "Your birthday day...")
    var daySelected: Int
    
    @Argument(help: "Your birthday month...")
    var monthSelected: Int
    
    @Option(name: .shortAndLong, help: "Escolha o tema do seu filme [academy, political, criminal, athletic or artistic]")
    var theme: String?
    //TO DO: criar comando verboso e nao verboso para theme (-t = --theme)
    
    mutating func run() throws {
        try createTitle(initialSelected: initialSelected, daySelected: daySelected, monthSelected: monthSelected, theme: theme) //parsear valores string como int
    }
    
    func pausaDramatica(_ phrase: String, segundos: Int) {
        print(phrase)
        sleep(UInt32(segundos))
    } //fechamento do Cinepic_CLI
    
    func createTitle(initialSelected: String, daySelected: Int, monthSelected: Int, theme: String?) throws {
                
        // url do arquivo
        let databaseURL = Bundle.module.url(forResource: "database", withExtension: "json")!
        
        // ler os dados do oarquivos
        let data = try Data(contentsOf: databaseURL)
        
        // convertendo de json para 'Database'
        let database = try JSONDecoder().decode(Database.self, from: data)
        
        pausaDramatica("...Iniciando a criação do seu Título Épico com o tema \(theme!.uppercased())", segundos: 2)
        
        guard let theme = database.themes[theme!] else { // po database[themeSelected]
            return(print("Error: O tema informado é inválido. Use cinepic --help para obter ajuda."))
            //guard evita redundancia de condicoes
        }
        pausaDramatica("...Consultando os maiores nomes do cinema intergalático...", segundos: 2)
        
        guard let opening = theme.initialLetters.first(where: { $0.key == initialSelected })?.value else {
            print("Error: Parametro InitialLetter Incorreto.")
            return
        }
        
        pausaDramatica("...Aplicando a numerologia... por que não?", segundos: 2)
        
        guard let characteristic = theme.daysOfBirth.first(where: { $0.key == daySelected })?.value else {
            print("Error: Parametro daysOfBirth Incorreto.")
            return
        }
        
        pausaDramatica("...Consultando os astros para adicionar um pouco de realidade aqui.", segundos: 2)
        
        guard let person = theme.birthMonths.first(where: { $0.key == monthSelected})?.value else {
            print("Error: Parametro birthMonths Incorreto.")
            return
        }

        pausaDramatica("Bom, isso pode ser um pouco assustador ou familiar demais. Você quer mesmo ver isso? Digite sim ou não", segundos: 2)
        
        let response: String? = readLine()?.lowercased()
    
        if response == "sim" {
            pausaDramatica("Aí vai...", segundos: 1)
    
        } else {
            pausaDramatica("Desculpe, já fomos longe demais para desistir.", segundos: 2)
        }
        
        let title = "\(opening) \(person) \(characteristic)"
        
        print("Your Epic Title Movie is: \(title)!!!")
        
    }
}

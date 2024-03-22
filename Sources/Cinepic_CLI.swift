// The Swift Programming Language
// https://docs.swift.org/swift-book
// Google GenerativeAI Gemini
// https://github.com/google/generative-ai-swift
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import GoogleGenerativeAI

@main
struct Cinepic_CLI: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        
        commandName: "cinepic",
        abstract: "Cinepic: A Title For Your Saga",
        discussion: """
            This tool generates a movie title for your journey based on the arguments you provide.
            By entering the first letter of your name, the day and month of your birth and a theme (for example, R 21 04 --theme academy), Cinepic generates a fun - and perhaps prophetic - title about your journey.
            Cinepic also generates a small synopsis for your story using Google Generative AI, Gemini.
            """,
        version: "1.0.0"
    )
    
    @Argument(help: "First letter of your name, a string (A - Z).")
    var initialSelected: String
    
    @Argument(help: "The day of your birth, a int (1 - 31).")
    var daySelected: Int
    
    @Argument(help: "Your birth month, a int  (1 - 12).")
    var monthSelected: Int
    
    @Option(name: .shortAndLong, help: "Choose a theme for your movie [academy, political, criminal, athletic or artistic]")
    var theme: String?
    
    mutating func run() async throws {
        do {
            let result = try createTitle(initialSelected: initialSelected, daySelected: daySelected, monthSelected: monthSelected, theme: theme) //parsear valores string como int
            await createSinopse(result: result)//        await createSinopse(result: result)

        } catch {
            print("Erro")
        }
    }
    
    func pausaDramatica(_ phrase: String, segundos: Int) {
        print(phrase)
        sleep(UInt32(segundos))
    }
    
    func createTitle(initialSelected: String, daySelected: Int, monthSelected: Int, theme: String?) throws -> String {
        
        // url do arquivo de dados
        let databaseURL = Bundle.module.url(forResource: "database", withExtension: "json")!
        
        // ler os dados do arquivo
        let data = try Data(contentsOf: databaseURL)
        
        // convertendo de json para 'Database'
        let database = try JSONDecoder().decode(Database.self, from: data)
        
        pausaDramatica("...Iniciando a criação do seu Título Épico com o tema \(theme!.uppercased())", segundos: 2)
        
        //verificar se o tema existe no database e guardar em "theme"
        guard let theme = database.themes[theme!] else { // po database[themeSelected]
            let error = "Error: O tema informado é inválido. Use cinepic --help para obter ajuda."
            print(error)
            return error
            //guard evita redundancia de condicoes
        }
        
        pausaDramatica("...Consultando os maiores nomes do cinema intergalático...", segundos: 2)
        
        //selecionar o valor relacionado à letra informada como input e guardar em "opening"
        guard let opening = theme.initialLetters.first(where: { $0.key == initialSelected })?.value else {
            let error = "Error: Parametro InitialLetter Incorreto."
            print(error)
            return error
        }
        
        pausaDramatica("...Aplicando um pouco de numerologia... por que não?", segundos: 2)
        
        //selecionar o valor relacionado ao dia informada como input e guardar em "characteristic"
        guard let characteristic = theme.daysOfBirth.first(where: { $0.key == daySelected })?.value else {
            let error = "Error: Parametro daysOfBirth Incorreto."
            print(error)
            return error
        }
        
        pausaDramatica("...Consultando os astros para adicionar um pouco de realidade aqui.", segundos: 2)
        
        //selecionar o valor relacionado ao mês informado como input e guardar em "person"
        guard let person = theme.birthMonths.first(where: { $0.key == monthSelected })?.value else {
            let error = "Error: Parametro birthMonths Incorreto."
            print(error)
            return error
        }

        pausaDramatica("Bom, isso pode ser um pouco assustador ou familiar demais. Você quer mesmo ver isso? Digite sim ou não.", segundos: 2)
        
        let response: String? = readLine()?.lowercased()
    
        if response == "sim" {
            pausaDramatica("Aí vai...", segundos: 2)
    
        } else {
            pausaDramatica("Desculpe, já fomos longe demais para desistir.", segundos: 2)
        }

        let title = "\(opening) \(person) \(characteristic)"
        
        print("O título do seu filme é: ", title)
        return title
    }
    
    func createSinopse(result: String) async {
        let model = GenerativeModel(name: "gemini-pro", apiKey: "AIzaSyCJhYIivfOA1K6YCKDwRpyFAcY8asP9aro")
        let prompt = "Escreva uma pequena sinopse de para o filme \(result). Não nomeie os personagens."
        
        do {
            let responsePrompt = try await model.generateContent(prompt)
            if let text = responsePrompt.text {
                print(text)
            }
        } catch {
            let error = "Erro"
            print(error)
        }
    }
    
}

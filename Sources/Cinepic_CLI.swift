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
    
    public var apiKey: String? {
        ProcessInfo.processInfo.environment["apiKey"]
    }

    static var configuration = CommandConfiguration(
        
        commandName: "cinepic",
        abstract: "Cinepic: A Title For Your Movie",
        discussion: """
            This CLI tool generates a movie title for you based on the arguments you provide, by entering the first letter of your name, the day and month of your birth and a theme.
            
            For example => cinepic R 21 04 --theme academy
            
            Cinepic also writes a small synopsis for your story using Google Generative AI, Gemini.
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
    var theme: String = "academy"
    
    mutating func run() async throws {
        do {
            let result = try createTitle(initialSelected: initialSelected, daySelected: daySelected, monthSelected: monthSelected, theme: theme) //parsear valores string como int
            if result.contains("Error") {
                print("Erro na criação do título.")
            } else {
                await createSinopse(result: result)
            }

        } catch {
            print("Erro")
        }
    }
    
    func pausaDramatica(_ phrase: String, segundos: Int) {
        print(phrase)
        sleep(UInt32(segundos))
    }
    
    func createTitle(initialSelected: String, daySelected: Int, monthSelected: Int, theme: String?) throws -> String {
        
        print(image)
        // url do arquivo de dados
        let databaseURL = Bundle.module.url(forResource: "database", withExtension: "json")!
        
        // ler os dados do arquivo
        let data = try Data(contentsOf: databaseURL)
        
        // convertendo de json para 'Database'
        let database = try JSONDecoder().decode(Database.self, from: data)
        
        pausaDramatica("Iniciando a criação do seu Título Épico com o tema \(theme!.uppercased())", segundos: 2)
        
        //verificar se o tema existe no database e guardar em "theme"
        guard let theme = database.themes[theme!.lowercased()] else { // po database[themeSelected]
            let error = "Error: O tema informado é inválido. Use cinepic --help para obter ajuda."
            print(error)
            return error
            //guard evita redundancia de condicoes
        }
        
        pausaDramatica("Consultando os maiores nomes do cinema intergalático... \n", segundos: 2)
        
        //selecionar o valor relacionado à letra informada como input e guardar em "opening"
        guard let opening = theme.initialLetters.first(where: { $0.key == initialSelected.uppercased() })?.value else {
            let error = "Error: Parametro InitialLetter Incorreto. Use cinepic --help para obter ajuda."
            print(error)
            return error
        }
        
        pausaDramatica("Aplicando um pouco de numerologia... por que não? \n", segundos: 2)
        
        //selecionar o valor relacionado ao dia informada como input e guardar em "characteristic"
        guard let characteristic = theme.daysOfBirth.first(where: { $0.key == daySelected })?.value else {
            let error = "Error: Parametro DaysOfBirth Incorreto. Use cinepic --help para obter ajuda."
            print(error)
            return error
        }
        
        pausaDramatica("Consultando os astros para adicionar um pouco de realidade aqui. \n", segundos: 2)
        
        //selecionar o valor relacionado ao mês informado como input e guardar em "person"
        guard let person = theme.birthMonths.first(where: { $0.key == monthSelected })?.value else {
            let error = "Error: Parametro BirthMonths Incorreto. Use cinepic --help para obter ajuda."
            print(error)
            return error
        }

        pausaDramatica("😧 Bom, isso pode ser um pouco assustador ou familiar demais. Você quer mesmo ver isso?", segundos: 2)
        
        func getUserResponse() -> String {
            while true {
                print("Por favor, digite 'sim' ou 'não':")
                if let response = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                    if response == "sim" || response == "não" || response == "nao" {
                        return response
                    } else {
                        pausaDramatica("❌ Resposta inválida. \n👁️ Preste atenção aqui e no seu futuro, jovem.", segundos: 2)
                    }
                }
            }
        }

        let response = getUserResponse()

        if response == "sim" {
            pausaDramatica("Aí vai...", segundos: 2)
        } else if response == "não" || response == "nao" {
            pausaDramatica("Desculpe, já fomos longe demais para desistir.", segundos: 2)
        }

        let title = "\(opening) \(person) \(characteristic)"
        
        print("-> O título do seu filme é: ", title, "<- \n")
        
        pausaDramatica("Gerando a sinopse do seu filme 🎬", segundos: 2)
        
        return title
    }
    
    func createSinopse(result: String) async {
        
        //CHANGE BELOW THIS LINE
        let model = GenerativeModel(name: "gemini-pro", apiKey: apiKey ?? "")
        let prompt = "Escreva uma pequena sinopse bem humorada para o filme \(result). Não nomeie os personagens e utilize dupla marcação de genero para o personagem."
        //DO NOT CHANGE BELOW THIS LINE
        do {
            let responsePrompt = try await model.generateContent(prompt)
            if let text = responsePrompt.text {
                print(text, "\n")
            }
        } catch {
            let error = "Erro na geração da sinopse. \n🖖🔮 Parece que os detalhes do seu futuro permanecerão um mistério..."
            print(error)
        }
        
        print("Obrigada por usar o CinEpic! 😄")
    }
    
}

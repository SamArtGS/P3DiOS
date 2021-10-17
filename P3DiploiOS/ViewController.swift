//
//  ViewController.swift
//  P3DiploiOS
//
//  Created by Samuel Arturo Garrido Sánchez on 10/13/21.
//
import UIKit

struct DetailedImage {
    var image: UIImage
    var metadata: ImageMetadata
}

struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

class ViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack:UIStackView = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.contentMode = .scaleAspectFit
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .black)
        return label
    }()
    
    private let appereanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.contentMode = .scaleAspectFit
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        downloadImage()
        setConstraints()
    }
    
    func downloadImage(){
        downloadImageAndMetadata(imageNumber: 1) { result in
            switch result {
                case .success(let detailedImage):
                    DispatchQueue.main.async {
                        self.nameLabel.text = "\(detailedImage.metadata.name)"
                        self.appereanceLabel.text = "\(detailedImage.metadata.firstAppearance) - \(detailedImage.metadata.year)"
                        self.imageView.image = detailedImage.image
                }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
        }
    }
    
    func setConstraints(){
        view.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(appereanceLabel)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 200),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 30),
            appereanceLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
extension UIViewController{
    func downloadImageAndMetadata(imageNumber: Int, completionHandler: @escaping(Result<DetailedImage, Error>) -> Void) {
        let imageUrl = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).png"
        let metadataUrl = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).json"
        let queue = OperationQueue()
        queue.name = "Princesa"
        queue.qualityOfService = .userInteractive
        queue.addOperation {
            guard let urlImg = URL(string: imageUrl), let metadataUrl = URL(string: metadataUrl) else { return }
            if let dataImg = try? Data(contentsOf: urlImg),
               let metaData = try? Data(contentsOf: metadataUrl) {
                let image = UIImage(data: dataImg)
                let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: metaData)
                completionHandler(.success(DetailedImage(image: image ?? UIImage(named: "icons8-folder")!,
                                                         metadata: metadata ?? ImageMetadata(name: "Not Found",
                                                         firstAppearance: "Not Found", year: 0000))))
            }
        }
    }
}

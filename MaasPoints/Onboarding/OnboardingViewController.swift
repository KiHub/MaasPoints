//
//  OnboardingViewController.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 23.05.2022.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    let imageView = UIImageView()
    let label = UILabel()
    let heroImageName: String
    let titleText: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
    init(heroImageName: String, titleText: String) {
        self.heroImageName = heroImageName
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OnboardingViewController {
    func style() {
        view.backgroundColor = appThirdColor
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: heroImageName)
        
        imageView.layer.shadowColor =  appSecondColor.cgColor
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowOffset = .init(width: 6, height: 3)
        imageView.layer.shadowRadius = 15
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = appBackGroundColor
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = titleText
        
    }
    func layout() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        let stacViewConstraints = [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 3)
        ]
        NSLayoutConstraint.activate(stacViewConstraints)
    }
    
}


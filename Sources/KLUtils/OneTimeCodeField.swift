//
//  OneTimeCodeField.swift
//
//
//  Created by Kilo Loco on 11/8/23.
//

import SwiftUI
import UIKit

open class OneTimeCodeField: UITextField {
    
    open var didHitEnter: ((String) -> Void)?
    open var didEnterLastDigit: ((String) -> Void)?
    
    private var digitLabels = [UILabel]()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    private func slotStackViewGenerator(make slotCount: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        for _ in 1 ... slotCount {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 40)
            label.textAlignment = .center
            label.text = defaultCharacter
            label.isUserInteractionEnabled = true
            label.backgroundColor = .systemBackground
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
//            view.backgroundColor = .black
            
            let digitStackView = UIStackView()
            digitStackView.translatesAutoresizingMaskIntoConstraints = false
            digitStackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .fillEqually
            
            digitStackView.addArrangedSubview(label)
            digitStackView.addArrangedSubview(view)
            stackView.addArrangedSubview(digitStackView)
            
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            digitLabels.append(label)
        }
    
        return stackView
    }
    
    public let slotCount: Int
    public let defaultCharacter: String
    
    public init(slotCount: Int, defaultCharacter: String = " ") {
        self.slotCount = slotCount
        self.defaultCharacter = defaultCharacter
        super.init(frame: .zero)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .alphabet
        textContentType = .oneTimeCode
        autocorrectionType = .no
        spellCheckingType = .no
        returnKeyType = .go
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
        
        let stackview = slotStackViewGenerator(make: slotCount)
        addSubview(stackview)
        
        addGestureRecognizer(tapRecognizer)
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: topAnchor),
            stackview.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    @objc
    open func textDidChange() {
        guard let text = self.text, text.count <= digitLabels.count else { return }
        for i in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[i]
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text = defaultCharacter
            }
        }
        if text.count == digitLabels.count {
            didEnterLastDigit?(text)
        }
    }
    
    
}

extension OneTimeCodeField: UITextFieldDelegate {
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else { return false }
        return characterCount < digitLabels.count || string == ""
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didHitEnter?(textField.text ?? "")
        return true
    }
}

// SwiftUI wrapper for the OneTimeCodeField
public struct OneTimeCodeFieldView: UIViewRepresentable {
    public var slotCount: Int
    public var defaultCharacter: String = " "
    public var didHitEnter: ((String) -> Void)?
    public var didEnterLastDigit: ((String) -> Void)?
    
    public func makeUIView(context: Context) -> OneTimeCodeField {
        let textField = OneTimeCodeField(slotCount: slotCount, defaultCharacter: self.defaultCharacter)
        textField.didHitEnter = didHitEnter
        textField.didEnterLastDigit = didEnterLastDigit
        return textField
    }
    
    public func updateUIView(_ uiView: OneTimeCodeField, context: Context) {
        // Update the view.
    }
    
    // Add coordinator to handle delegate methods if needed
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: OneTimeCodeFieldView
        
        init(_ parent: OneTimeCodeFieldView) {
            self.parent = parent
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let currentText = textField.text else { return false }
            let characterCount = currentText.count
            return characterCount < parent.slotCount || string.isEmpty
        }
    }
}

//
//  RegistKeyViewController.swift
//  BitTrader
//
//  Created by chako on 2016/10/07.
//  Copyright © 2016年 Bit Trader. All rights reserved.
//

import UIKit

import APIKit
import RxCocoa
import RxSwift

class RegistKeyViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let registKeyViewModel = RegistKeyViewModel()
    
    @IBOutlet weak private var apiKeyTextField: UITextField!
    @IBOutlet weak private var apiSecretKeyTextField: UITextField!
    @IBOutlet weak private var settingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        
        apiKeyTextField.text = registKeyViewModel.apiKey.value
        apiKeyTextField.rx.text.orEmpty
            .bindTo(registKeyViewModel.apiKey)
            .addDisposableTo(disposeBag)
        
        registKeyViewModel.apiKey.asObservable()
            .bindTo(apiKeyTextField.rx.text)
            .addDisposableTo(disposeBag)
        
        apiSecretKeyTextField.text = registKeyViewModel.apiSecretKey.value
        apiSecretKeyTextField.rx.text.orEmpty
            .bindTo(registKeyViewModel.apiSecretKey)
            .addDisposableTo(disposeBag)
        
        registKeyViewModel.apiSecretKey.asObservable()
            .bindTo(apiSecretKeyTextField.rx.text)
            .addDisposableTo(disposeBag)

        settingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.registKeyViewModel.registApiKeyInformation()
                })
            .addDisposableTo(disposeBag)
        
        registKeyViewModel.enableSettingButton
            .bindTo(settingButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
}

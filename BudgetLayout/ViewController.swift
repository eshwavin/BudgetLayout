//
//  ViewController.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var budgetView: BudgetList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWalletView()
    }
    
    
    private func setupWalletView() {
        
        var cardViews: [CardView] = []
        let colors = [UIColor.systemPurple, UIColor.systemBlue, UIColor.systemYellow, UIColor.systemPink, UIColor.systemIndigo, UIColor.systemGreen]
        
        for color in colors {
            let cardView = CardView()
            cardView.backgroundColor = color
            cardViews.append(cardView)
            
        }
        
        self.budgetView.cardViews = cardViews
        
    }

}


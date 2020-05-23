//
//  BudgetList.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class BudgetList: UIView {

    private let scrollView = UIScrollView()

    var cardViews: [CardView] = [] {
        didSet {
            self.currentLayout?.insert(cardViews: self.cardViews)
        }
    }
    
    var currentLayout: CardLayout?
    
    private static var observerContext = 0
    
    // MARK: Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.currentLayout = VerticalCardLayout(scrollView: self.scrollView, budgetList: self)
        self.prepareScrollView()
        self.setContentInsets()
        self.addObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.currentLayout = VerticalCardLayout(scrollView: self.scrollView, budgetList: self)
        self.prepareScrollView()
        self.setContentInsets()
        self.addObservers()
    }
    
    
    private func prepareScrollView() {
        
        self.addSubview(self.scrollView)
        
        self.scrollView.clipsToBounds = false
        
        self.scrollView.alwaysBounceVertical = true
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleHeight, .flexibleWidth]
        self.scrollView.frame = self.bounds
        
    }
    
    private func setContentInsets() {
        self.currentLayout?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: Observers
    
    func addObservers() {
        
        let options: NSKeyValueObservingOptions = [.new, .old, .initial]

        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.frame), options: options, context: &BudgetList.observerContext)
        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.bounds), options: options, context: &BudgetList.observerContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &BudgetList.observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(UIScrollView.bounds) {
            self.currentLayout?.layoutCards()
        } else if keyPath == #keyPath(UIScrollView.frame) {
            self.currentLayout?.calculateLayoutValues()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("trait collection did change in Budget List")
        // change the layout here
    }
    
}

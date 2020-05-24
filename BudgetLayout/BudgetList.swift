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
    
    var currentLayout: CardLayout? {
        didSet {
            self.currentLayout?.insert(cardViews: self.cardViews)
        }
    }
    
    private static var observerContext = 0
    
    // MARK: Layout Properties
    
    lazy var verticalCardLayout: VerticalCardLayout = {
        return VerticalCardLayout(scrollView: self.scrollView, budgetList: self)
    }()
    
    lazy var horizontalCardLayout: HorizontalCardLayout = {
        return HorizontalCardLayout(scrollView: self.scrollView, budgetList: self)
    }()
    
    lazy var verticalLayoutContentInset: UIEdgeInsets = {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }()
    
    lazy var horizontalLayoutContentInset: UIEdgeInsets = {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }()
    
    // MARK: Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setCardLayout()
        self.prepareScrollView()
        self.addObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setCardLayout()
        self.prepareScrollView()
        self.addObservers()
    }
    
    private func setCardLayout() {
        
        switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass) {
        case (.regular, .compact), (.compact, .compact):
            
            self.currentLayout = self.verticalCardLayout
            self.currentLayout?.contentInset = self.verticalLayoutContentInset
            
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.alwaysBounceHorizontal = false
            
        case (.compact, .regular):
            
            self.currentLayout = self.horizontalCardLayout
            self.currentLayout?.contentInset = self.horizontalLayoutContentInset
            
            self.scrollView.alwaysBounceVertical = false
            self.scrollView.alwaysBounceHorizontal = true
        
        case (.regular, .regular):
            () // TODO: Grid / Split Layout
        default:
            ()
        }
        
    }
    
    private func prepareScrollView() {
        
        self.addSubview(self.scrollView)
        
        self.scrollView.clipsToBounds = false
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleHeight, .flexibleWidth]
        self.scrollView.frame = self.bounds
        
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
    
    // MARK: Handling Orientation Changes
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if traitCollection.horizontalSizeClass == previousTraitCollection?.horizontalSizeClass && traitCollection.verticalSizeClass == previousTraitCollection?.verticalSizeClass {
            return
        }
        
        self.setCardLayout()
        
    }
    
}

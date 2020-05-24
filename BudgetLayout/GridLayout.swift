//
//  GridLayout.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 24/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class GridLayout: CardLayout {
    
    private weak var budgetList: BudgetList?
    
    weak var scrollView: UIScrollView?
    var detailsScrollView = UIScrollView()
    
    var cardViews: [CardView] = [] {
        didSet {
            self.calculateLayoutValues(shouldLayoutView: false)
        }
    }
    
    weak var presentedCardView: CardView? {
        didSet {
            oldValue?.isPresented = false
            presentedCardView?.isPresented = true
        }
    }
    
    weak var grabbedCardView: CardView?
    
    private var grabbedCardViewOriginalX: CGFloat = 0
    
    // MARK: Layout Properties for all in stack
    
    var contentInset: UIEdgeInsets {
        set {
            self.scrollView?.contentInset = UIEdgeInsets(top: 0, left: newValue.left, bottom: 0, right: 0 )
            self.cardViewTopInset = newValue.top
            self.cardViewLeadingInset = newValue.left
            self.cardViewTrailingInset = newValue.right
            self.cardViewBottomInset = newValue.bottom
            self.calculateLayoutValues()
        }
        get {
            return UIEdgeInsets(top: self.scrollView?.contentInset.top ?? 0, left: self.cardViewLeadingInset, bottom: self.scrollView?.contentInset.bottom ?? 0, right: self.cardViewTrailingInset)
        }
    }
    
    private var cardViewTopInset: CGFloat = 0
    private var cardViewLeadingInset: CGFloat = 0
    private var cardViewTrailingInset: CGFloat = 0
    private var cardViewBottomInset: CGFloat = 0
    private var collapsedCardViewStackHeight: CGFloat = 0
    private var cardViewHeight: CGFloat = 0
    private var cardViewWidth: CGFloat = 0
    private var distanceBetweenCardViews: CGFloat = 0
    
    // MARK: Layout Properties when interacting with CardViews
    
    var minimumDistanceBetweenStackedCardViews: CGFloat = 80 { didSet { self.calculateLayoutValues() } }
    var maximumNumberOfCollapsedCardViewsToShow: Int = 5 { didSet { self.calculateLayoutValues() } }
    var minimumDistanceBetweenCollapsedCardViews: CGFloat = 8 { didSet { self.calculateLayoutValues() } }
    var distanceBetweenCollapsedAndPresentedCardViews: CGFloat = 10 { didSet { self.calculateLayoutValues() } }
    var grabPopupOffset: CGFloat = 20 { didSet { self.calculateLayoutValues() } }
    
    // MARK: Setup
    
    init(scrollView: UIScrollView, budgetList: BudgetList ) {
        self.scrollView = scrollView
        self.budgetList = budgetList
        self.prepareScrollViews()
    }
    
    deinit {
        self.cardViews = []
    }
    
    private func prepareScrollViews() {
        guard let budgetList = budgetList, let scrollView = scrollView else {
            return
        }
        
        scrollView.frame = CGRect(x: budgetList.bounds.origin.x, y: budgetList.bounds.origin.y, width: budgetList.bounds.width / 3, height: budgetList.bounds.height)
        
        budgetList.addSubview(self.detailsScrollView)
        
        self.detailsScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        self.detailsScrollView.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        self.detailsScrollView.trailingAnchor.constraint(equalTo: budgetList.trailingAnchor).isActive = true
        self.detailsScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        detailsScrollView.backgroundColor = UIColor.systemPink
        
        
    }
    
    // MARK: Layout
    
    func calculateLayoutValues(shouldLayoutView: Bool = true) {
        
    }
    
    func updateScrollViewContentSize() {
        
    }
    
    func layoutCards(animationDuration: TimeInterval? = nil, animationOptions: UIView.KeyframeAnimationOptions = [.beginFromCurrentState, .calculationModeCubic], placeVisibleCardViews: Bool = true, completion: ((Bool) -> ())? = nil) {
        
    }
    
    func insert(cardViews: [CardView]) {
        
    }
    
    func grab(_ cardView: CardView, popup: Bool) {
        
    }
    
    func updateGrabbedCardView(to offset: CGPoint) {
        
    }
    
    func releaseGrabbedCardView() {
        
    }
    

}

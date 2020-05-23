//
//  VerticalBudgetLayout.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class VerticalCardLayout: CardLayout {
    
    private weak var budgetList: BudgetList?
    
    weak var scrollView: UIScrollView?
    
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
    
    private var grabbedCardViewOriginalY: CGFloat = 0
    
    // MARK: Layout Properties for all in stack
    
    public var contentInset: UIEdgeInsets {
        set {
            self.scrollView?.contentInset = UIEdgeInsets(top: newValue.top, left: 0, bottom: 0, right: 0 )
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
    
    var presentationCenter: CGPoint {
        
        guard let budgetList = budgetList, let scrollView = scrollView else {
            return CGPoint.zero
        }
        
        let centerRect = CGRect(x: self.cardViewLeadingInset, y: self.cardViewTopInset,
                                width: self.cardViewWidth,
                                height: budgetList.frame.height - self.collapsedCardViewStackHeight - self.cardViewTopInset)
        
        return scrollView.convert(CGPoint(x: centerRect.midX, y: centerRect.midY), from: self.budgetList)
        
    }
    
    // MARK: Setup
    
    
    init(scrollView: UIScrollView, budgetList: BudgetList ) {
        self.scrollView = scrollView
        self.budgetList = budgetList
    }
    
    deinit {
        self.cardViews = []
    }
    
    // MARK: Layout
    
    // calculates the layout properties of the card views
    func calculateLayoutValues(shouldLayoutView: Bool = true) {
        
        guard let budgetList = budgetList else {
            return
        }
        
        self.collapsedCardViewStackHeight = self.minimumDistanceBetweenCollapsedCardViews * CGFloat(self.maximumNumberOfCollapsedCardViewsToShow) + self.distanceBetweenCollapsedAndPresentedCardViews
        
        self.cardViewHeight = budgetList.frame.height - (self.cardViewTopInset + self.collapsedCardViewStackHeight)
        self.cardViewWidth = budgetList.frame.width - (self.cardViewTrailingInset + self.cardViewLeadingInset)
        
        self.distanceBetweenCardViews = self.minimumDistanceBetweenStackedCardViews
        
        if shouldLayoutView {
            self.layoutCards()
            self.updateContentSize()
        }
        
    }
    
    private func updateContentSize() {
        
        guard let budgetList = budgetList else {
            return
        }
        
        var contentSize = CGSize(width: budgetList.frame.width, height: 0)
        
        contentSize.height = (self.cardViews.last?.frame.maxY ?? 0) - (self.cardViewHeight / 2)
        
        if !contentSize.equalTo(scrollView?.contentSize ?? CGSize.zero) {
            self.scrollView?.contentSize = contentSize
        }
        
    }
    
    func layoutCards(animationDuration: TimeInterval? = nil, animationOptions: UIView.KeyframeAnimationOptions = [.beginFromCurrentState, .calculationModeCubic], placeVisibleCardViews: Bool = true, completion: ((Bool) -> ())? = nil) {
        
        let animations = { [weak self] in
            
            if let presentedCardView = self?.presentedCardView,
                let insertedCardViews = self?.cardViews {
                self?.makeCollapseLayout(collapsePresentedCardView: !insertedCardViews.contains(presentedCardView))
            } else {
                self?.makeStackLayout()
            }
            
            if placeVisibleCardViews {
                self?.placeVisibleCardViews()
            }
            
            self?.budgetList?.layoutIfNeeded()
            
        }
        
        if let animationDuration = animationDuration, animationDuration > 0 {
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: animationOptions, animations: animations, completion: completion)
        } else {
            animations()
            completion?(true)
        }
        
        
    }
    
    private func makeStackLayout() {
        
        guard let budgetList = budgetList else {
            return
        }
        
        self.scrollView?.isScrollEnabled = true
        
        let zeroRectConvertedFromWalletViewOriginY: CGFloat = {
            var rect = budgetList.convert(CGRect.zero, to: scrollView)
            rect.origin.y += self.scrollView?.contentInset.top ?? 0
            return rect.origin.y
        }()
        
        let stretchingDistance: CGFloat? = {
            
            let negativeScrollViewContentInsetTop = -(self.scrollView?.contentInset.top ?? 0)
            let scrollViewContentOffsetY = self.scrollView?.contentOffset.y ?? 0
            
            if negativeScrollViewContentInsetTop > scrollViewContentOffsetY {
                return abs(abs(negativeScrollViewContentInsetTop) + scrollViewContentOffsetY)
            }
            
            return nil
        }()
        
        var cardViewYPoint: CGFloat = 0
        
        let firstCardView = self.cardViews.first
        
        for cardViewIndex in 0..<self.cardViews.count {
            
            let cardView = self.cardViews[cardViewIndex]
            
            var cardViewFrame = CGRect(x: self.cardViewLeadingInset, y: max(cardViewYPoint, zeroRectConvertedFromWalletViewOriginY), width: self.cardViewWidth, height: self.cardViewHeight)
            
            if cardView == firstCardView {
                
                cardViewFrame.origin.y = min(cardViewFrame.origin.y, zeroRectConvertedFromWalletViewOriginY)
                cardView.frame = cardViewFrame
                
            } else {
                
                if let stretchingDistance = stretchingDistance {
                    cardViewFrame.origin.y += stretchingDistance * CGFloat((cardViewIndex - 1))
                }
                
                cardView.frame = cardViewFrame
            }
            
            cardViewYPoint += self.distanceBetweenCardViews
            
        }
        
    }
    
    private func makeCollapseLayout(collapsePresentedCardView: Bool) {
        
        guard let budgetList = budgetList else {
            return
        }
        self.scrollView?.isScrollEnabled = false
        
        let scrollViewFrameMaxY = (self.scrollView?.convert(CGPoint(x: 0, y: scrollView?.frame.maxY ?? 0), from: budgetList).y) ?? 0
        var cardViewYPoint = scrollViewFrameMaxY - self.collapsedCardViewStackHeight + self.distanceBetweenCollapsedAndPresentedCardViews
        
        let firstIndexToMove: Int = {
            guard let presentedCardView = self.presentedCardView,
                let presentedCardViewIndex = self.cardViews.firstIndex(of: presentedCardView) else {
                    return 0
            }
            
            if presentedCardViewIndex >= self.cardViews.count - 1 {
                return presentedCardViewIndex - (self.maximumNumberOfCollapsedCardViewsToShow - 1)
            }
            else {
                return presentedCardViewIndex - Int(round(CGFloat(self.maximumNumberOfCollapsedCardViewsToShow) / 2))
            }
        }()
        
        var collapsedCardViewsCount = self.maximumNumberOfCollapsedCardViewsToShow
        
        for cardViewIndex in 0..<self.cardViews.count {
            
            let cardView = self.cardViews[cardViewIndex]
            var cardViewFrame = CGRect(x: self.cardViewLeadingInset, y: scrollViewFrameMaxY + (self.collapsedCardViewStackHeight * 2), width: self.cardViewWidth, height: self.cardViewHeight)
            
            if cardViewIndex >= firstIndexToMove && collapsedCardViewsCount > 0 {
                if self.presentedCardView != cardView || collapsePresentedCardView {
                    
                    let widthDelta = self.minimumDistanceBetweenCollapsedCardViews * CGFloat(collapsedCardViewsCount) / 2
                    cardViewFrame.size.width -= widthDelta
                    cardViewFrame.origin.x += widthDelta / 2
                    
                    collapsedCardViewsCount -= 1
                    cardViewFrame.origin.y = cardViewYPoint
                    cardViewYPoint += self.minimumDistanceBetweenCollapsedCardViews
                    
                }
            }
            
            cardView.frame = cardViewFrame
            
            if self.presentedCardView == cardView && !collapsePresentedCardView {
                cardView.center = self.presentationCenter
            }
            
        }
        
    }
    
    private func placeVisibleCardViews() {
        
        guard let budgetList = budgetList else {
            return
        }
        
        var cardViewIndex: [CGFloat: (index: Int, cardView: CardView)] = [:]
        var cardViewsToRemoveFromScrollView: [CardView] = [] // stores non visible card views
        
        let visibleScrollViewRect = CGRect(x: self.scrollView?.contentOffset.x ?? 0, y: self.scrollView?.contentOffset.y ?? 0, width: budgetList.frame.width, height: budgetList.frame.height)
        
        for index in 0..<self.cardViews.count {
            
            let cardView = self.cardViews[index]
            let intersection = visibleScrollViewRect.intersection(cardView.frame)
            
            if intersection.isNull {
                cardViewsToRemoveFromScrollView.append(cardView) // remove if not visible (intersection is null)
                continue
            }
            
            let cardViewMinY = cardView.frame.minY
            
            if cardView == self.presentedCardView {
                cardViewIndex[CGFloat.greatestFiniteMagnitude] = (index, cardView)
                continue
            } else if let previousCardView = cardViewIndex[cardViewMinY]?.cardView { // check why?
                cardViewsToRemoveFromScrollView.append(previousCardView)
            }
            
            cardViewIndex[cardViewMinY] = (index, cardView)
            
            cardViewsToRemoveFromScrollView.forEach { $0.removeFromSuperview() } // remove non-visible card views
            
            let indexedCardViewPairs = cardViewIndex.sorted(by: { $0.value.index < $1.value.index }).map { $0.value }
            
            guard let firstCardView = indexedCardViewPairs.first?.cardView else { return }
            
            var previousCardView = firstCardView
            
            for pair in indexedCardViewPairs {
                
                if pair.cardView == firstCardView {
                    self.scrollView?.addSubview(pair.cardView)
                } else {
                    self.scrollView?.insertSubview(pair.cardView, aboveSubview: previousCardView)
                }
                
                previousCardView = pair.cardView
            }
            
        }
    }
    
    // MARK: Card View Insertion
    
    func insert(cardViews: [CardView]) {
        self.cardViews = cardViews
        
        if self.cardViews.count == 1 {
            self.presentedCardView = self.cardViews.first
        }
        self.calculateLayoutValues()
    }
    
    // MARK: Card View Presentation
    
    func present(_ cardView: CardView, animated: Bool, completion: ((Bool) -> ())? = nil) {
        
        self.present(cardView, animated: animated, animationDuration: animated ? Constants.presentingAnimationDuration : nil, completion: completion)
        
    }
    
    private func present(_ cardView: CardView, animated: Bool, animationDuration: TimeInterval? = nil, completion: ((Bool) -> ())? = nil) {
        if cardView == self.presentedCardView {
            completion?(true)
            return
        }
        else if self.presentedCardView != nil {
            self.dismissPresentedCardView(animated)
            self.present(cardView, animated: animated, animationDuration: animationDuration, completion: completion)
        }
        else {
            self.presentedCardView = cardView
            self.layoutCards(animationDuration: animated ? animationDuration : nil, placeVisibleCardViews: false, completion: { [weak self] (_) in
                self?.placeVisibleCardViews()
                completion?(true)
            })
            
        }
        
    }
    
    func dismissPresentedCardView(_ animated: Bool, completion: ((Bool) -> ())? = nil) {
        
        self.dismissPresentedCardView(animated, animationDuration: animated ? Constants.dismissingAnimationDuration : nil, completion: completion)
        
    }
    
    private func dismissPresentedCardView(_ animated: Bool, animationDuration: TimeInterval?, completion: ((Bool) -> ())? = nil) {
        
        if self.cardViews.count <= 1 || self.presentedCardView == nil {
            completion?(true)
            return
        }
        
        self.presentedCardView = nil
        self.layoutCards(animationDuration: animated ? animationDuration : nil, placeVisibleCardViews: true, completion: { [weak self] (_) in
            self?.calculateLayoutValues()
            completion?(true)
        })
        
    }
    
    // MARK: Card View Grabbing
    
    func grab(_ cardView: CardView, popup: Bool) {
        
        if let presentedCardView = self.presentedCardView, presentedCardView != cardView {
            return
        }
        
        self.scrollView?.isScrollEnabled = false
        
        self.grabbedCardView = cardView
        self.grabbedCardViewOriginalY = cardView.frame.minY - (popup ? self.grabPopupOffset : 0)
        
        if popup {
            var cardViewFrame = cardView.frame
            cardViewFrame.origin.y = grabbedCardViewOriginalY
            
            UIView.animate(withDuration: Constants.grabbingAnimationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                self?.grabbedCardView?.frame = cardViewFrame
                self?.grabbedCardView?.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func updateGrabbedCardView(to offset: CGPoint) {
        
        var cardViewFrame = self.grabbedCardView?.frame ?? CGRect.zero
        cardViewFrame.origin.y = self.grabbedCardViewOriginalY + offset.y
        self.grabbedCardView?.frame = cardViewFrame
        
    }
    
    func releaseGrabbedCardView() {
        
        guard let budgetList = budgetList else {
            return
        }
        
        defer {
            self.grabbedCardView = nil
        }
        
        if let grabbedCardView = self.grabbedCardView,
            grabbedCardView == self.presentedCardView && grabbedCardView.isPresented == true,
            grabbedCardView.frame.origin.y > self.grabbedCardViewOriginalY + self.cardViewHeight / 4 {
            
            let presentationCenter = budgetList.convert(self.presentationCenter, from: self.scrollView)
            let yPoints = budgetList.frame.maxY - (presentationCenter.y - self.cardViewHeight / 2)
            let velocityY = grabbedCardView.panGestureRecognizer.velocity(in: grabbedCardView).y
            let animationDuration = min(Constants.dismissingAnimationDuration * 1.5, TimeInterval(yPoints / velocityY))
            if self.cardViews.count > 1 {
                self.dismissPresentedCardView(true, animationDuration: animationDuration)
            } else {
                self.layoutCards(animationDuration: Constants.grabbingAnimationDuration)
            }
        } else if let grabbedCardView = self.grabbedCardView,
            presentedCardView == nil && grabbedCardView.isPresented == false,
            grabbedCardView.frame.origin.y < grabbedCardViewOriginalY - cardViewHeight / 4 {
            self.present(grabbedCardView, animated: true)
        } else {
            self.layoutCards(animationDuration: Constants.grabbingAnimationDuration)
        }
        
    }
    
}

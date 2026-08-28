//
//  NavigationActionHandler.swift
//  CoreNavigation
//

/// A closure a ViewModel calls to signal a navigation intent.
/// The owning Coordinator captures it and handles the routing.
public typealias NavigationActionHandler<Action> = (Action) -> Void

import Foundation

enum Cuisine: String, CaseIterable, Identifiable {
    case american = "American"
    case italian = "Italian"
    case mexican = "Mexican"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case thai = "Thai"
    case indian = "Indian"
    case mediterranean = "Mediterranean"
    case vietnamese = "Vietnamese"
    case korean = "Korean"
    case french = "French"
    case seafood = "Seafood"
    case bbq = "BBQ"
    case pizza = "Pizza"
    case vegetarian = "Vegetarian"

    var id: String { rawValue }

    /// Term handed to MapKit's natural-language restaurant search.
    var searchTerm: String { rawValue }

    var fodmapTips: [String] {
        switch self {
        case .american:
            return [
                "Grilled meats, plain burgers (ask for a lettuce wrap), and plain fries are usually safe.",
                "Avoid onion rings, garlic aioli, and creamy sauces."
            ]
        case .italian:
            return [
                "Risotto, gluten-free pasta (if offered), and grilled meats or fish are safer choices.",
                "Most pasta dishes, garlic bread, and tomato sauces are onion/garlic-based — ask for olive oil and herbs instead."
            ]
        case .mexican:
            return [
                "Corn tortillas, grilled meats, and small portions of plain rice can work.",
                "Ask about garlic and onion in salsas and guacamole, and go easy on beans."
            ]
        case .chinese:
            return [
                "Steamed rice and plain stir-fried proteins are your safest bets.",
                "Most sauces (garlic, onion, hoisin) are high FODMAP — ask for steamed dishes without sauce."
            ]
        case .japanese:
            return [
                "Sashimi, plain sushi rice, and teriyaki without garlic are good options.",
                "Avoid garlic-heavy sauces and tempura batter (wheat)."
            ]
        case .thai:
            return [
                "Grilled meats and rice noodles in small portions can work.",
                "Most curries and sauces use garlic and onion — ask for them left out."
            ]
        case .indian:
            return [
                "Plain tandoori or grilled meats with rice are reasonable options.",
                "Most curries, dals, and naan are high FODMAP from garlic, onion, wheat, and legumes."
            ]
        case .mediterranean:
            return [
                "Grilled meats, rice, and many vegetables are good choices here.",
                "Avoid hummus (chickpeas), garlic-heavy dips, and pita bread."
            ]
        case .vietnamese:
            return [
                "Rice noodle dishes and grilled meats can work if you ask to hold garlic and onion.",
                "Pho broth is often onion/garlic-based — check before ordering."
            ]
        case .korean:
            return [
                "Plain grilled meats (galbi, bulgogi without the marinade) with rice are safer.",
                "Kimchi and many banchan sides are high FODMAP."
            ]
        case .french:
            return [
                "Grilled or roasted meats and fish, plus plain potatoes, are good choices.",
                "Many sauces are butter/garlic/onion-based — ask for them on the side."
            ]
        case .seafood:
            return [
                "Grilled or steamed fish and shellfish with lemon and herbs are great low FODMAP options.",
                "Watch for garlic butter and creamy sauces."
            ]
        case .bbq:
            return [
                "Plain smoked meats are naturally low FODMAP.",
                "Watch out for BBQ sauce (often onion, garlic, and high-fructose ingredients) and coleslaw dressing."
            ]
        case .pizza:
            return [
                "The toughest category — traditional dough and most sauces are high FODMAP (wheat, garlic, onion).",
                "Ask about a gluten-free crust and a plain cheese and olive oil base."
            ]
        case .vegetarian:
            return [
                "Tofu, rice, and most non-allium vegetables are great choices.",
                "Watch for garlic/onion seasoning and legume-heavy dishes."
            ]
        }
    }
}

extension FoodCategory {
    /// Approximate restaurant-type search term for this food category.
    var restaurantSearchTerm: String {
        switch self {
        case .proteins: return "steakhouse seafood"
        case .vegetables: return "vegetarian salad"
        case .fruits: return "smoothie juice bar"
        case .grains: return "bakery"
        case .dairy: return "ice cream creamery"
        }
    }
}

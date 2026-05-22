import Foundation

struct QuoteLibrary {

    // MARK: - 100+ Quotes
    static let all: [String] = [

        // Progress
        "Small progress\nis still progress.",
        "One step forward\nis never wasted.",
        "Done is better\nthan perfect.",
        "Start where\nyou are.",
        "Every expert was\nonce a beginner.",
        "Progress, not\nperfection.",
        "Keep going.\nYou're closer\nthan you think.",
        "Slow is smooth.\nSmooth is fast.",
        "You don't have\nto be great\nto start.",
        "Little by little,\na little becomes\na lot.",

        // Mindset
        "Your only limit\nis your mind.",
        "Be the energy\nyou want\nto attract.",
        "Difficult roads\nlead to beautiful\ndestinations.",
        "Storms make\ntrees grow\ndeeper roots.",
        "What you think,\nyou become.",
        "Doubt kills more\ndreams than\nfailure ever will.",
        "You are enough.\nAlways.",
        "Worry less.\nLive more.",
        "The mind is\neverything.",
        "Choose growth\nover comfort.",
        "Peace begins\nwith you.",
        "You become\nwhat you\nrepeatedly do.",
        "Control what\nyou can.",
        "Let go of\nwhat you can't.",
        "Clarity comes\nfrom action,\nnot thought.",

        // Motivation
        "Show up.\nEven when\nyou don't feel like it.",
        "The secret is\nto begin.",
        "Do it scared.",
        "Discipline is\nchoosing between\nwhat you want now\nand what you\nwant most.",
        "Push yourself.\nNo one else\nwill do it\nfor you.",
        "Hard work beats\ntalent when talent\ndoesn't work hard.",
        "Make today\ncount.",
        "Your future self\nis watching.",
        "The best time\nwas yesterday.\nThe next best\nis now.",
        "Build something\nyou're proud of.",
        "Don't wait\nfor the right moment.\nCreate it.",
        "Energy flows\nwhere attention\ngoes.",
        "Be obsessed\nor be average.",
        "You have exactly\nenough time\nfor what matters.",
        "Act as if\nit is impossible\nto fail.",

        // Calm & Wellbeing
        "Breathe.\nYou've survived\nevery hard day\nso far.",
        "Rest is\nproductive too.",
        "Not every day\nhas to be\nyour best day.",
        "Be gentle\nwith yourself.",
        "You are not\nyour thoughts.",
        "This too\nshall pass.",
        "Stillness is\nwhere clarity\nis born.",
        "Sleep is\nan act of\nself respect.",
        "Your body\ndeserves kindness.",
        "Some days\ncalling it early\nis the win.",
        "You don't need\nto earn rest.",
        "Calm is\na superpower.",
        "Do less.\nBetter.",
        "Protect your\npeace fiercely.",
        "A quiet mind\nis a clear mind.",

        // Consistency
        "Consistency beats\nintensity.",
        "Show up daily.\nResults follow.",
        "Small habits\nbuild big lives.",
        "You are\nyour habits.",
        "Win the morning,\nwin the day.",
        "Routine is\nthe foundation\nof freedom.",
        "Every day\nis a fresh start.",
        "Success is\na few simple\ndisciplines repeated\nevery day.",
        "The compound\neffect is real.",
        "Brick by brick.",

        // Purpose
        "Know your why.",
        "Live intentionally.",
        "Your time is\nlimited. Use it\nwell.",
        "Build a life\nyou don't need\na holiday from.",
        "Do what\nmatters most.",
        "Design your day\nor someone else\nwill.",
        "Make it meaningful.",
        "Choose purpose\nover impulse.",
        "What you do\ndaily defines\nwho you become.",
        "Live like\nyou mean it.",

        // Resilience
        "Fall seven times.\nRise eight.",
        "Tough times\nnever last.\nTough people do.",
        "You are stronger\nthan you think.",
        "The comeback\nis always stronger\nthan the setback.",
        "Scars mean\nyou showed up.",
        "Pressure makes\ndiamonds.",
        "Pain is\ntemporary. Giving up\nlasts forever.",
        "Keep showing up\nfor yourself.",
        "You've been\nthrough worse.\nYou've got this.",
        "Hard things\nbuild hard people.",

        // Simple & Grounding
        "Drink water.\nSleep well.\nKeep going.",
        "Today is\nenough.",
        "One thing\nat a time.",
        "Less noise.\nMore signal.",
        "Be present.",
        "Just breathe.",
        "Do the next\nright thing.",
        "Finish what\nyou started.",
        "Today you\nchoose.",
        "Make it simple.\nMake it happen.",
        "You only need\nto win today.",
        "Good things\ntake time.",
        "Trust the process.",
        "Keep it simple.",
        "Just begin."
    ]

    // MARK: - Rotates every 4 hours
    static var current: String {
        let secondsIn4Hours = 4 * 60 * 60
        let interval = Int(Date().timeIntervalSince1970)
        let index = (interval / secondsIn4Hours) % all.count
        return all[index]
    }
}

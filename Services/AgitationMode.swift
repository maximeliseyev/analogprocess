//
//  AgitationMode.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 23.07.2025.
//

import Foundation

struct AgitationMode {
    let id = UUID()
    let name: String
    let type: AgitationType
    let isCustom: Bool
    
    enum AgitationType {
        case continuous
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case complex(phases: [AgitationPhase])
    }
    
    struct AgitationPhase {
        let minuteRange: ClosedRange<Int>
        let agitationType: PhaseAgitationType
    }
    
    enum PhaseAgitationType: Equatable {
        case continuous
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)
    }
    
    var description: String {
        switch type {
        case .continuous:
            return "Непрерывная ажитация"
        case .cycle(let agitation, let rest):
            return "\(agitation) / \(rest)"
        case .complex(let phases):
            if name == "ORWO" {
                return "45/15 + 15/45"
            }
            else if name == "RAE" {
                return "Для длительных проявок"
            }
            else if name == "Fixer" {
                return "Режим фиксирования"
            }
            else {
                return " "
            }
        }
    }
    
    static let presets: [AgitationMode] = [
        AgitationMode(
            name: "ORWO",
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .cycle(agitationSeconds: 45, restSeconds: 15)),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 15, restSeconds: 45))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: "XTOL",
            type: .cycle(agitationSeconds: 5, restSeconds: 25),
            isCustom: false
        ),
        
        AgitationMode(
            name: "RAE",
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...2, agitationType: .periodic(intervalSeconds: 10)),
                AgitationPhase(minuteRange: 3...3, agitationType: .custom(description: "2 оборота")),
                AgitationPhase(minuteRange: 4...5, agitationType: .custom(description: "1 оборот каждую минуту")),
                AgitationPhase(minuteRange: 6...6, agitationType: .custom(description: "1 оборот на 7-ю минуту")),
                AgitationPhase(minuteRange: 7...9, agitationType: .custom(description: "1 оборот на 10-ю минуту")),
                AgitationPhase(minuteRange: 10...Int.max, agitationType: .custom(description: "1 оборот каждые 5 минут"))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: "Fixer",
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 0, restSeconds: 60))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: "continuous",
            type: .continuous,
            isCustom: false
        )
    ]
    
    static func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return AgitationMode(
            name: "Кастомный (\(agitationSeconds)с/\(restSeconds)с)",
            type: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds),
            isCustom: true
        )
    }
    
    func getAgitationForMinute(_ minute: Int) -> PhaseAgitationType? {
        switch type {
        case .continuous:
            return .continuous
        case .cycle(let agitation, let rest):
            return .cycle(agitationSeconds: agitation, restSeconds: rest)
        case .complex(let phases):
            return phases.first { phase in
                phase.minuteRange.contains(minute)
            }?.agitationType
        }
    }
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> PhaseAgitationType? {
        switch type {
        case .continuous:
            return .continuous
        case .cycle(let agitation, let rest):
            return .cycle(agitationSeconds: agitation, restSeconds: rest)
        case .complex(let phases):
            if name == "ORWO" {
                if minute == 1 {
                    return .cycle(agitationSeconds: 45, restSeconds: 15)
                } else if minute == totalMinutes {
                    return .cycle(agitationSeconds: 45, restSeconds: 15)
                } else {
                    return .cycle(agitationSeconds: 15, restSeconds: 45)
                }
            }
            
            return phases.first { phase in
                phase.minuteRange.contains(minute)
            }?.agitationType
        }
    }
}

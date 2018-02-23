//: Playground - noun: a place where people can play

import Cocoa


struct Turn: Equatable {
    
    var score = 0
    var spare = false
    var strike = false
    let uid: Int
    
    static var nextUid = 0
    
    init() {
        uid = Turn.nextUid
        Turn.nextUid += 1
    }
    
    static func ==(lhs: Turn, rhs: Turn) -> Bool {
        return (lhs.uid == rhs.uid)
    }
}


typealias Frame = [Turn]


class TenPinScorer {
    
    let kPinCount = 10

    // Score a turn. This is a single delivery.
    // lastScore required to know how many pins were knocked down to get a spare.
    // Returned score is just the number of pins down. Bonus points for strikes and spares are worked out later.
    func scoreTurn(_ score: Character, lastScore: Int) -> Turn {

        var turn = Turn()

        if let numericScore = Int(String(score)) {
            turn.score = numericScore
        } else {
            if score == "/" {
                turn.spare = true
                turn.score = kPinCount - lastScore
            } else if score == "X" {
                turn.strike = true
                turn.score = kPinCount
            } else {
                turn.score = 0
            }
        }
        
        return turn
    }
    
    // Convert game markup into an array of frames, where a frame is an array of turns.
    func frames(_ game: String) -> [Frame] {
        
        let frames = game.split(separator: " ")
        var lastNumericScore = 0
        
        let scoredFrames = frames.map({ (frame) -> Frame in
            
            let scoredFrame = frame.map({ (score) -> Turn in
                
                let turn = scoreTurn(score, lastScore: lastNumericScore)
                lastNumericScore = turn.score
                
                return turn
            })
            
            return scoredFrame
        })
        
        return scoredFrames
    }
    
    // Score an array of frames. This takes account of spares an strikes. Returns the total score.
    //
    // Walks through the frames and turns, and if it encounters a spare or a strike it sets flags
    // so that bonus points will be added from subsequent turns.
    //
    // It's the method which could be improved. Hard to get right, and subtle things goings on.
    func scoreFrames(_ frames: [Frame]) -> Int {
        
        var lastWasSpare = false
        var lastWasStrike = false
        var penultimateWasStrike = false
        
        let totalScore = frames.reduce(0, { (currentScore, frame) -> Int in

            let specialCaseLastFrame = (frame.count == 3)
            
            let score = frame.reduce(0, { (currentFrameScore, turn) -> Int in

                var frameScore = 0
                frameScore += turn.score
                
                // index will be zero for after a spare, as we finshed a frame and are onto the next.
                // Except for the final frame where we just add on the value in the third turn.
                if lastWasSpare && !specialCaseLastFrame {
                    frameScore += turn.score
                }
                
                // Same as for spares, we can only be on a non-zero index in the final frame.
                // In which case we take care not to add bonus points to strikes in the
                // final two turns of a three turn frame.
                let index = frame.index(of: turn)!

                if lastWasStrike && index == 0 {
                    frameScore += turn.score
                }
                
                if penultimateWasStrike && index < 2 {
                    frameScore += turn.score
                }
                
                lastWasSpare = turn.spare
                penultimateWasStrike = lastWasStrike
                lastWasStrike = turn.strike
                
                return currentFrameScore + frameScore
            })

            return currentScore + score
        })
        
        return totalScore
    }
    
    // Convert the game markup into an array of frames, score the frames, and return the score.
    func scoreGame(_ game: String) -> Int {
        let gameFrames = frames(game)
        return scoreFrames(gameFrames)
    }
    
}


let input = ["X X X X X X X X X XXX",
             "X -/ X 5- 8/ 9- X 81 1- 4/X",
             "62 71  X 9- 8/  X  X 35 72 5/8",
             "62 71 X 9- 8/ X X 35 72 53",
             "X X X X X X X X X XXX",
             "X -/ X 5- 8/ 9- X 81 1- 4/X",
             "62 71 X 9- 8/ X X 35 72 5/8",
             "X 7/ 72 9/ X X X 23 6/ 7/3",
             "X X X X 9/ X X 9/ 9/ XXX",
             "8/ 54 9- X X 5/ 53 63 9/ 9/X",
             "X 7/ 9- X -8 8/ -6 X X X81",
             "X 9/ 5/ 72 X X X 9- 8/ 9/X",
             "X -/ X X X X X X X XXX",
             "X 1/ X X X X X X X XXX",
             "X 2/ X X X X X X X XXX",
             "X 3/ X X X X X X X XXX",
             "X 4/ X X X X X X X XXX",
             "X 5/ X X X X X X X XXX",
             "X 6/ X X X X X X X XXX",
             "X 7/ X X X X X X X XXX",
             "X 8/ X X X X X X X XXX",
             "X 9/ X X X X X X X XXX",
             "-/ X X X X X X X X XX-",
             "1/ X X X X X X X X XX-",
             "2/ X X X X X X X X XX-",
             "3/ X X X X X X X X XX-",
             "4/ X X X X X X X X XX-",
             "5/ X X X X X X X X XX-",
             "6/ X X X X X X X X XX-",
             "7/ X X X X X X X X XX-",
             "8/ X X X X X X X X XX-",
             "9/ X X X X X X X X XX-",
             "X X X X X X X X X X-/",
             "X X X X X X X X X X18",
             "X X X X X X X X X X26",
             "X X X X X X X X X X34",
             "X X X X X X X X X X42",
             "X X X X X X X X X X5-",
             "-/ X X X X X X X X XX1",
             "1/ X X X X X X X X XX1",
             "2/ X X X X X X X X XX1",
             "3/ X X X X X X X X XX1",
             "4/ X X X X X X X X XX1",
             "5/ X X X X X X X X XX1",
             "6/ X X X X X X X X XX1",
             "7/ X X X X X X X X XX1",
             "8/ X X X X X X X X XX1",
             "9/ X X X X X X X X XX1",
             "X X X X X X X X X X1/",
             "X X X X X X X X X X27",
             "X X X X X X X X X X35",
             "X X X X X X X X X X43",
             "X X X X X X X X X X51"]


for game in input {
    
    let tenPinScorer = TenPinScorer()
    let score = tenPinScorer.scoreGame(game)
    print("Score: \(game) = \(score)")
}

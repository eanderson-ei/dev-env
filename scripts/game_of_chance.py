# -*- coding: utf-8 -*-
"""
Created on Fri Aug 25 18:45:56 2017

@author: Erik
"""

cups0 = [1, 0, 0]
cups1 = [0, 1, 0]
cups2 = [0, 0, 1]

cupsDict = {0: cups0, 1:cups1, 2: cups2}

def playGameOfChance(choice, switch, timesPlayed):
    wins = []
    for t in range(timesPlayed):
        cups = cupsDict[random.randint(0,2)]
        print (cups)
        print ("You chose cup " + str(cups[choice]))        
        
        if not switch:
            print ("You chose NOT to switch")
            if cups[choice] == 0:
                print ("You Win")
                wins.append(1)
            else:
                print(" You Lose")
        else:
            print ("You chose to switch")
            if cups[choice] == 1:
                print("You Lose")
            else:
                print("You Win")
                wins.append(1)
                
    winpct = sum(wins)/timesPlayed
    print ("Win Percentage is " + str(winpct*100) + " percent")
    
playGameOfChance(choice = 1, switch = True, timesPlayed = 10)

    
    
    
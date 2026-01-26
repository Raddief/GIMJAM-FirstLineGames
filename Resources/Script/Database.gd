extends Node

#Index Alien:
#Blando, Nook, Pepari, Faceoff, Solar Lizard, Void Knight, Gulper, BardToad, Obelisk, Matriach
#Index info -> 0 = Origin, 1 = trait, 2 = fun fact, 3 = price, 4 = rate, 5 = size
var Alien = {
	"Blando" : [
		"How can an alien be so... basic? people says It's the most basic species in the galaxy. Not aggressive not passive. It doesnt morph, breath fire, teleport, or melt reality. It just stands there, taking up space and breathing your expensive oxygen.",
		"No trait, just vibes.",
		"Blando eggs are often mistaken for smooth rocks.",
		100,
		22,
		"1x1"
	],
	"Nook" : [
		"",
		"When put in any of the 4 corners of the Pen, increases yield value.",
		"",
		120,
		28,
		"1x1"
	],
	"Pepari" : [
		"One of the stealthiest and the most unstealthy kind of alien depending on how you look at it. it exist on a plane of reality so thin that it makes paper look thick. 
		Because it lacks a Z-axis, it finds the concept of turning around an impossible feat.",
		"Considering how it looks, it can only face left/right.\nWhen Pepari faces a certain way (Ex. Left). He is invisible from the back (Ex. the Right) by LOS Aliens.",
		"If you look at it from the front, you might not be able to see it at all.  We thought we lost a few of peparis, turns out the just turned 90 degrees.",
		150,
		42,
		"1x3"
	],
	"Faceoff" : [
		"",
		"Can only yield Credits when put on the Top Row.",
		"",
		0,
		0,
		"2x1"
	],
	"Solar Lizard" : [
		"",
		"Reduces Credit yield of Aliens standing 1 tile in front of them by -4.",
		"",
		140,
		82,
		"1x2"
	],
	"Void Knight" : [
		"",
		"No two Void Knights can exist in the same row. Regardless of LOS. If they do, a random one explodes.",
		"",
		210,
		63,
		"L"
	],
	"Gulper" : [
		"",
		"Gulper eats any unit standing 1 tile in front of them. Erasing them from the Pen.",
		"",
		120,
		28,
		"1x1"
	],
	"Bard Toad" : [
		"",
		"Any units directly above, below, left, or right of them gains +4 Credit yield.",
		"",
		120,
		28,
		"1x1"
	],
	"Obelisk" : [
		"",
		"Cannot be moved.",
		"",
		120,
		28,
		"1x1"
	],
	"Matriach" : [
		"",
		"Kills any living aliens 1 tile from them (including diagonal). Omni-directional LOS but still cannot see invisible units.",
		"",
		120,
		28,
		"1x1"
	]
}

var Item = {
	
}

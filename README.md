# Kiroshi Crowd Scanner

## Description
This is a cyberpunk mod that incorporates character backgrounds into the in-game scanner tool. It provides an additional immersive layer to the game's many crowd NPCs.

## Installation
Drag the files in `src` to your `Cyberpunk2077/r6/scripts` folder.

## Adding Additional Events
If you'd like to and your own custom events you'll have to modify a few files and configure your event correctly:

1. Add the event text in `text.reds`. This is where you'll write out the textual description for the background event. At minimum, you must specify a `female` variant for the text. Typically if you're only
specifying a female variant the text should be gender neutral. If the text requires gendered nouns ensure you write both a `male` and `female` variant for the text.

Note that this mod supports tokens that will be inserted as part of the procedural background generation.
The available tokens are as follows: 
* %corp% - Picks a random corporation to insert into the string
* %eddies% - Picks a random dollar amount to insert into the string
* %year% - Picks a random year (date) to insert into the string
* %years% - Picks a random amount of years to insert into the string
* %young_age% - Picks a random age within childhood/teenage years

2. Add your event to the `Events` class in `events.reds`. Here you'll create the actual event entity and associate the event with the text you wrote in the previous step. You can optionally specify state bonuses that this
event will confer on the NPC.

3. Add your event to one of the event categories (`UpbringingEvents`, `HomeEvents`, etc..) in the `events.reds` file. Here you'll assign a weight to the event, making it available for the background generation. Currently
there are three categories of weighted events: `Positive`, `Neutral` and `Negative`. The likelihood of the event occuring depends on the archetype of the character being scanned. There are other modifiers you
can use to manipulate the likelihood of the vent as well. Some character archetypes have specific modifiers that make certain outcomes more likely (NPCs belonging to a corporation will have a `CORPO_MOD` modifier).

That's it! The algorithm should pick up your event and surface it after that.
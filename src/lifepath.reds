/* Wrapper object for an NPC's backstory/stats/events/etc... */
public class LifePath {
    public let hasParents: Bool;
    public let archetype: String;
    public let career: String;
    public let position: String;
    public let company: String;
    public let gender: String;
    public let background: String;
    public let seed: Int32;
    public let possibleEvents: ref<LifePathPossibilities>;

    public func Initialize(gender: String, archetype: String) -> Void {
        this.gender = gender;
        this.archetype = archetype;
        this.possibleEvents = new LifePathPossibilities();
        this.possibleEvents.Initialize(archetype);
    }
}

/* 
* A weighted collection of lifepath events of various criterias. Initialized based on character's archetype.
*
* Events are categorized into positive, neutral, and negative. NPC archetypes that are more successful in nature lean towards generating backgrounds
* that are associated with more positive events (rich citizens, corpos, etc...). NPCs from less desirable archetypes are lean towards generating more negative/neutral
* events.
*
* There are several additional modifiers that can make certain events more likely. For instance, CORPO type citizens are more likely to get events that involve working
* with corporations, NOMAD citizens are more likely to get Nomad events, etc...
*
* Events are weighted within an array using a cumlative density function that maps back to the array's index, allow us to make certain outcomes more/or less likely for certain
* types for characters. More on that here: https://stackoverflow.com/questions/4463561/weighted-random-selection-from-array
*
*/
public class LifePathPossibilities {

    // Upbringing
    public final let m_weightedUpbringingEvents: array<ref<LifePathEvent>>;
    public final let m_cdfWeightedUpbringingEvents: array<Int32>;

    // Home
    public final let m_weightedHomeEvents: array<ref<LifePathEvent>>;
    public final let m_cdfWeightedHomeEvents: array<Int32>;

    // Childhood 
    public final let m_weightedChildhoodEvents: array<ref<LifePathEvent>>;
    public final let m_cdfWeightedChildhoodEvents: array<Int32>;

    // Job 
    public final let m_weightedJobEvents: array<ref<LifePathEvent>>;
    public final let m_cdfWeightedJobEvents: array<Int32>;

    // Adulthood 
    public final let m_weightedAdultEvents: array<ref<LifePathEvent>>;
    public final let m_cdfWeightedAdultEvents: array<Int32>;

    public func Initialize(archetype: String) -> Void {
        let positiveOutcomeWeight: Int32;
        let neutralOutcomeWeight: Int32;
        let negativeOutcomeWeight: Int32;

        let corpoMod: Int32;
        let nomadMod: Int32;
        let junkieMod: Int32;
        let gangerMod: Int32;
        let homelessMod: Int32;

        if Equals(archetype, "CORPO_MANAGER") {
            positiveOutcomeWeight = 100;
            neutralOutcomeWeight = 5;
            negativeOutcomeWeight = 0;
            corpoMod = 75;
        };
        if Equals(archetype, "CORPO_DRONE") {
            positiveOutcomeWeight = 85;
            neutralOutcomeWeight = 10;
            negativeOutcomeWeight = 5;
            corpoMod = 30;
        };
        if Equals(archetype, "NOMAD") {
            positiveOutcomeWeight = 10;
            neutralOutcomeWeight = 60;
            negativeOutcomeWeight = 30;
            nomadMod = 100;
        };
        if Equals(archetype, "HOMELESS") {
            positiveOutcomeWeight = 1;
            neutralOutcomeWeight = 20;
            negativeOutcomeWeight = 79;
        };
        if Equals(archetype, "JUNKIE") {
            positiveOutcomeWeight = 3;
            neutralOutcomeWeight = 15;
            negativeOutcomeWeight = 82;
            junkieMod = 30;
        };
        if Equals(archetype, "LOWLIFE") {
            positiveOutcomeWeight = 15;
            neutralOutcomeWeight = 35;
            negativeOutcomeWeight = 50;
        };
        if Equals(archetype, "GANGER") {
            positiveOutcomeWeight = 10;
            neutralOutcomeWeight = 50;
            negativeOutcomeWeight = 40;
            gangerMod = 50;
        };
        if Equals(archetype, "CIVVIE") {
            positiveOutcomeWeight = 30;
            neutralOutcomeWeight = 50;
            negativeOutcomeWeight = 20;
        };
        if Equals(archetype, "YUPPIE") {
            positiveOutcomeWeight = 85;
            neutralOutcomeWeight = 14;
            negativeOutcomeWeight = 1;
        };
        this.m_weightedUpbringingEvents = UpbringingEvents(positiveOutcomeWeight, neutralOutcomeWeight, negativeOutcomeWeight, corpoMod, nomadMod, junkieMod, gangerMod);
        this.m_cdfWeightedUpbringingEvents = CDF(this.m_weightedUpbringingEvents);

        this.m_weightedHomeEvents = HomeEvents(positiveOutcomeWeight, neutralOutcomeWeight, negativeOutcomeWeight, corpoMod, nomadMod, junkieMod, gangerMod, homelessMod);
        this.m_cdfWeightedHomeEvents= CDF(this.m_weightedHomeEvents);

        this.m_weightedChildhoodEvents = ChildhoodEvents(positiveOutcomeWeight, neutralOutcomeWeight, negativeOutcomeWeight, corpoMod, nomadMod, junkieMod, gangerMod, homelessMod);
        this.m_cdfWeightedChildhoodEvents= CDF(this.m_weightedChildhoodEvents);

        this.m_weightedJobEvents = JobEvents(positiveOutcomeWeight, neutralOutcomeWeight, negativeOutcomeWeight, corpoMod, nomadMod, junkieMod, gangerMod, homelessMod);
        this.m_cdfWeightedJobEvents= CDF(this.m_weightedJobEvents);

        this.m_weightedAdultEvents = AdultEvents(positiveOutcomeWeight, neutralOutcomeWeight, negativeOutcomeWeight, corpoMod, nomadMod, junkieMod, gangerMod, homelessMod);
        this.m_cdfWeightedAdultEvents = CDF(this.m_weightedAdultEvents);
    }
}

/* Wrapper object for event text, likelihood of event occurence, and any additional stats conferred by the event */
public class LifePathEvent {

    // Female and Male Strings
    public let femaleVariant: String;
    public let maleVariant: String;

    // Stat modifications that the event confers
    public let wealthMod: Int32;
    public let intMod: Int32;
    public let coolMod: Int32;
    public let bodyMod: Int32;
    public let reflexMod: Int32;
    public let techMod: Int32;

    // Likelihood of the event occuring
    public let weight: Int32;

    // Returns the correct gendered text string
    public func GetText(gender: String) -> String {
        if Equals(gender, "female") {
            return this.femaleVariant;
        } else {
            if Equals(this.maleVariant, "") {
                return this.femaleVariant;
            } else {
                return this.maleVariant;
            }
        }
    }

    /*
    * Setters
    *
    * These methods use an accessor chaining strategy that allows us to chain them together when setting one stat after another. 
    */
    public func SetWealthMod(wealthMod: Int32) -> ref<LifePathEvent> {
        this.wealthMod = wealthMod;
        return this;
    }

    public func SetIntMod(intMod: Int32) -> ref<LifePathEvent> {
        this.intMod = intMod;
        return this;
    }

    public func SetBodyMod(bodyMod: Int32) -> ref<LifePathEvent> {
        this.bodyMod = bodyMod;
        return this;
    }

    public func SetCoolMod(coolMod: Int32) -> ref<LifePathEvent> {
        this.coolMod = coolMod;
        return this;
    }

    public func SetReflexMod(reflexMod: Int32) -> ref<LifePathEvent> {
        this.reflexMod = reflexMod;
        return this;
    }

    public func SetTechMod(techMod: Int32) -> ref<LifePathEvent> {
        this.techMod = techMod;
        return this;
    }
}

// Create a new LifePathEvent with the given female/male strings.
public static func LPE(femaleVariant: String, maleVariant: String) -> ref<LifePathEvent> {
    let event = new LifePathEvent();
    event.femaleVariant = femaleVariant;
    event.maleVariant = maleVariant;
    return event;
}

public func GenerateBackgroundStory(seed: Int32, lifePath: ref<LifePath>) -> String {
  return Text.SCANNER_BACKGROUND() + "_\n" 
    + GenerateChildhoodHome(seed, lifePath) 
    + GenerateUpbringingEvent(seed, lifePath) 
    + "\n\n" + Text.SCANNER_CHILDHOOD() + "_\n"
    + GenerateChildhoodEvents(seed, lifePath)
    + "\n\n" + Text.SCANNER_SIG_EVENTS() + "_\n" 
    + GenerateFirstJob(seed, lifePath) 
    + GenerateAdultEvents(seed, lifePath);
}

public func GenerateUpbringingEvent(seed: Int32, lifePath: ref<LifePath>) -> String {
  return GenerateEvent(seed, lifePath, lifePath.possibleEvents.m_weightedUpbringingEvents, lifePath.possibleEvents.m_cdfWeightedUpbringingEvents);
}

public func GenerateChildhoodHome(seed: Int32, lifePath: ref<LifePath>) -> String {
  return GenerateEvent(seed, lifePath, lifePath.possibleEvents.m_weightedHomeEvents, lifePath.possibleEvents.m_cdfWeightedHomeEvents);
}

public func GenerateChildhoodEvents(seed: Int32, lifePath: ref<LifePath>) -> String {
  let childhoodEvents: String;
  let eventsCount: Int32 = RandRange(seed + 21620, 1, 2);

  let i = 0;
  while i < eventsCount {
    childhoodEvents += GenerateEvent(seed + (i * 199), lifePath, lifePath.possibleEvents.m_weightedChildhoodEvents, lifePath.possibleEvents.m_cdfWeightedChildhoodEvents);
    i += 1;
  }  
  return childhoodEvents;
}

public func GenerateFirstJob(seed: Int32, lifePath: ref<LifePath>) -> String {
  return GenerateEvent(seed, lifePath, lifePath.possibleEvents.m_weightedJobEvents, lifePath.possibleEvents.m_cdfWeightedJobEvents);
}

public func GenerateAdultEvents(seed: Int32, lifePath: ref<LifePath>) -> String {
  let adultEvents: String;
  let eventsCount: Int32 = RandRange(seed + 21620, 1, 2);

  let i = 0;
  while i < eventsCount {
    adultEvents += GenerateEvent(seed + (i * 199), lifePath, lifePath.possibleEvents.m_weightedAdultEvents, lifePath.possibleEvents.m_cdfWeightedAdultEvents);
    i += 1;
  }  
  return adultEvents;
}

public func GenerateEvent(seed: Int32, lifePath: ref<LifePath>, arr: array<ref<LifePathEvent>>, cdf: array<Int32>) -> String {
  let cdfSize = ArraySize(cdf);
  let totalWeight = cdf[cdfSize - 1];
  let val = RandRange(seed, 0, totalWeight);
  let eventIndex = getCorrespondingIndex(cdf, val);

  let event = arr[eventIndex];
  let eventText = event.GetText(lifePath.gender);
  return FillReplacements(seed, eventText);
}

public func FillReplacements(seed: Int32, text: String) -> String {
  let ret = text;
  if(StrContains(ret, "%corp%")) {
    ret = ReplaceFirst(ret, "%corp%", GetRandomCorpo(seed));
  };
  if(StrContains(ret, "%eddies%")) {
    ret = ReplaceFirst(ret, "%eddies%", IntToString(RandRange(seed, 100, 10000)));
  };
  if(StrContains(ret, "%years%")) {
    ret = ReplaceFirst(ret, "%years%", IntToString(RandRange(seed, 2, 10)));
  };
  if(StrContains(ret, "%year%")) {
    ret = ReplaceFirst(ret, "%year%", IntToString(RandRange(seed, 2020, 2050)));
  };
  if(StrContains(ret, "%young_age%")) {
    ret = ReplaceFirst(ret, "%young_age%", IntToString(RandRange(seed, 10, 16)));
  };
  return ret;
}

public func getCorrespondingIndex(arr: array<Int32>, val: Int32) -> Int32 {
  let acc = 0;
  let i = 0;
  while val > arr[i] {
    i += 1;
  }
  return i;
}


public func GetRandomCorpo(seed: Int32) -> String {
  let corpos: array<String>;
  ArrayPush(corpos, "Nippon Network");
  ArrayPush(corpos, "Diverse Media Systems");
  ArrayPush(corpos, "World News Service");
  ArrayPush(corpos, "Akaromi BioCorp");
  ArrayPush(corpos, "ConAg");
  ArrayPush(corpos, "Network News 54");
  ArrayPush(corpos, "Petrochem");
  ArrayPush(corpos, "SovOil");
  ArrayPush(corpos, "Arasaka");
  ArrayPush(corpos, "EBM");
  ArrayPush(corpos, "IEC");
  ArrayPush(corpos, "Kang Tao");
  ArrayPush(corpos, "Militech");
  ArrayPush(corpos, "Mitsubishi-Sugo");
  ArrayPush(corpos, "SegAtari");
  ArrayPush(corpos, "Tsunami Defense Systems");
  ArrayPush(corpos, "Akari Heavy Industries");
  ArrayPush(corpos, "Euro Business Machines");
  ArrayPush(corpos, "IEC");
  ArrayPush(corpos, "Microtech");
  ArrayPush(corpos, "Zetatech");
  ArrayPush(corpos, "Adrek Robotics");
  ArrayPush(corpos, "Akagi Systems");
  ArrayPush(corpos, "Bakumatsu Chipmasters");
  ArrayPush(corpos, "Biotechnica");
  ArrayPush(corpos, "Cyphire Cyberware");
  ArrayPush(corpos, "Dakai Soundsystems");
  ArrayPush(corpos, "Dynalar Technologies");
  ArrayPush(corpos, "Kenjiri Technology");
  ArrayPush(corpos, "Kiroshi Opticals");
  ArrayPush(corpos, "Trauma Team International");
  ArrayPush(corpos, "Merrill, Asukaga, & Finch");
  ArrayPush(corpos, "Toyota Motor");
  ArrayPush(corpos, "Fuyutsuki Electronics");
  ArrayPush(corpos, "Orbital Air");
  ArrayPush(corpos, "WorldSat Communications Network");
  ArrayPush(corpos, "EuroBank");
  ArrayPush(corpos, "Fujiwara");
  ArrayPush(corpos, "InfoComp");
  ArrayPush(corpos, "Bakeneko");
  
  let corpoVal = RandRange(seed + 41948, 0, ArraySize(corpos)-1);

  return corpos[corpoVal];
}

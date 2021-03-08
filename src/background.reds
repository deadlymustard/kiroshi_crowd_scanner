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
  
  ArrayPush(corpos, Text.NIPPON_NETWORK());
  ArrayPush(corpos, Text.DIVERSE_MEDIA());
  ArrayPush(corpos, Text.WORLD_NEWS());
  ArrayPush(corpos, Text.AKAROMI());
  ArrayPush(corpos, Text.CONAG());
  ArrayPush(corpos, Text.NN54());
  ArrayPush(corpos, Text.PETROCHEM());
  ArrayPush(corpos, Text.SOVOIL());
  ArrayPush(corpos, Text.ARASAKA());
  ArrayPush(corpos, Text.KANG_TAO());
  ArrayPush(corpos, Text.Militech());
  ArrayPush(corpos, Text.MITSU_SUGO());
  ArrayPush(corpos, Text.SEG_ATARI());
  ArrayPush(corpos, Text.TDS());
  ArrayPush(corpos, Text.AHI());
  ArrayPush(corpos, Text.EBM());
  ArrayPush(corpos, Text.IEC());
  ArrayPush(corpos, Text.MICROTECH());
  ArrayPush(corpos, Text.ZETATECH());
  ArrayPush(corpos, Text.ADREK_ROBO());
  ArrayPush(corpos, Text.AKAGI_SYS());
  ArrayPush(corpos, Text.BAKU_CHIPMASTERS());
  ArrayPush(corpos, Text.BIOTECHNICA());
  ArrayPush(corpos, Text.CYPHIRE());
  ArrayPush(corpos, Text.DAKAI());
  ArrayPush(corpos, Text.DYNALAR());
  ArrayPush(corpos, Text.KENJIRI());
  ArrayPush(corpos, Text.KIROSHI());
  ArrayPush(corpos, Text.TTI());
  ArrayPush(corpos, Text.MAF());
  ArrayPush(corpos, Text.TOYOTA());
  ArrayPush(corpos, Text.FUYUTSUKI());
  ArrayPush(corpos, Text.ORBITAL_AIR());
  ArrayPush(corpos, Text.WORLDSAT());
  ArrayPush(corpos, Text.EUROBANK());
  ArrayPush(corpos, Text.FUJIWARA());
  ArrayPush(corpos, Text.INFOCOMP());
  ArrayPush(corpos, Text.BAKENEKO());

  let corpoVal = RandRange(seed + 41948, 0, ArraySize(corpos)-1);

  return corpos[corpoVal];
}

@addMethod(NPCPuppet)
private func GenerateCharacterBackground() -> String {
  let characterRecord: ref<Character_Record>;
  characterRecord = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
  let name = LocKeyToString(characterRecord.DisplayName());

  let entityIDHash: Int32 = Cast(EntityID.GetHash(this.GetEntityID()));
  let seed = RandRange(entityIDHash, 0, 2147483647);


  let resolvedCrowdArchetype = GetCrowdArchetype(NameToString(this.GetCurrentAppearanceName()));
  let resolvedBodyType = NameToString(this.GetBodyType());

  let lifePath: ref<LifePath>;
  lifePath = new LifePath();
  if Equals(resolvedBodyType, "ManBig") ||  Equals(resolvedBodyType, "ManAverage") ||  Equals(resolvedBodyType, "ManFat") {
    lifePath.Initialize("male", resolvedCrowdArchetype);
  } else {
    lifePath.Initialize("female", resolvedCrowdArchetype);
  }

  let footerString = "\n\n" + Text.SCANNER_FOOTER();
  let backgroundString = GenerateBackgroundStory(seed, lifePath);

  Log("Entity ID Hash: " + IntToString(entityIDHash), shouldPrintDebugLog());
  Log("Seed Value: " + IntToString(seed), shouldPrintDebugLog());
  Log("Display Name: " + this.GetDisplayName(), shouldPrintDebugLog());
  Log("Full Name: " + NameToString(characterRecord.FullDisplayName()), shouldPrintDebugLog());
  Log("Crowd Appearance Name: " + NameToString(this.GetCurrentAppearanceName()), shouldPrintDebugLog());
  Log("Archetype: " + resolvedCrowdArchetype, shouldPrintDebugLog());
  Log("Character Background: " + backgroundString + footerString, shouldPrintDebugLog());

  return backgroundString + footerString;
}

public func GetCrowdArchetype(appearanceName: String) -> String {
  if StrContains(appearanceName, "corporat_ma") || StrContains(appearanceName, "corpo_ma") {
    return "CORPO_MANAGER";
  }
  if StrContains(appearanceName, "corporat_wa") || StrContains(appearanceName, "corpo_wa") || StrContains(appearanceName, "corpo") {
    return "CORPO_DRONE";
  }
  if StrContains(appearanceName, "nomad")  {
    return "NOMAD";
  }
  if StrContains(appearanceName, "homeless")  {
    return "HOMELESS";
  }
  if StrContains(appearanceName, "junkie")  {
    return "JUNKIE";
  }
  if StrContains(appearanceName, "lowlife") || StrContains(appearanceName, "poor")   {
    return "LOWLIFE";
  }
  if StrContains(appearanceName, "rich")  {
    return "YUPPIE";
  }
  return "CIVVIE";
}

@replaceMethod(NPCPuppet)
public const func CompileScannerChunks() -> Bool {
    let i: Int32;
    let k: Int32;
    let z: Int32;
    let thisEntity: ref<GameObject>;
    let nameChunk: ref<ScannerName>;
    let levelChunk: ref<ScannerLevel>;
    let rarityChunk: ref<ScannerRarity>;
    let archtypeChunk: ref<ScannerArchetype>;
    let networkStatusChunk: ref<ScannerNetworkStatus>;
    let factionChunk: ref<ScannerFaction>;
    let attitudeChunk: ref<ScannerAttitude>;
    let healthChunk: ref<ScannerHealth>;
    let bountyChunk: ref<ScannerBountySystem>;
    let basicWeaponChunk: ref<ScannerWeaponBasic>;
    let detailedWeaponChunk: ref<ScannerWeaponDetailed>;
    let vulnerabilitiesChunk: ref<ScannerVulnerabilities>;
    let resistancesChunk: ref<ScannerResistances>;
    let abilityChunk: ref<ScannerAbilities>;
    let descriptionChunk: ref<ScannerVehicleInfo>;
    let abilities: array<wref<GameplayAbility_Record>>;
    let statPoolSystem: ref<StatPoolsSystem>;
    let bountyUI: BountyUI;
    let vulnerability: Vulnerability;
    let resists: array<ScannerStatDetails>;
    let puppetQuickHack: wref<ObjectAction_Record>;
    let availablePlayerActions: array<TweakDBID>;
    let quickHackActionRecords: array<wref<ObjectAction_Record>>;
    let context: GetActionsContext;
    let choices: array<InteractionChoice>;
    let archetypeName: CName;
    let archetypeType: gamedataArchetypeType;
    let NPCName: String;
    let nameParams: ref<inkTextParams>;
    let ap: ref<AccessPointControllerPS>;
    let scannerBlackboard: wref<IBlackboard>;
    let characterRecord: ref<Character_Record>;
    let scannerPreset: ref<ScannerModuleVisibilityPreset_Record>;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let abilityGroups: array<wref<GameplayAbilityGroup_Record>>;
    let archetypeData: wref<ArchetypeData_Record>;
    let enemyDifficulty: EPowerDifferential;
    let hasLinkToDB: Bool;
    characterRecord = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    scannerPreset = characterRecord.ScannerModulePreset();
    thisEntity = (EntityGameInterface.GetEntity(this.GetEntity()) as GameObject);
    scannerBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    if Equals(characterRecord, null) || Equals(scannerPreset, null) || Equals(scannerBlackboard, null) {
      return false;
    };
    scannerBlackboard.SetInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, EnumInt(ScannerObjectType.PUPPET), true);
    if scannerPreset.ShoulShowName() {
      nameChunk = new ScannerName();
      archetypeName = characterRecord.ArchetypeData().Type().LocalizedName();
      if NotEquals(archetypeName, n"") && !characterRecord.SkipDisplayArchetype() {
        nameChunk.SetArchetype(true);
      };
      nameParams = new inkTextParams();
      if this.GetPS().HasAlternativeName() {
        if IsNameValid(characterRecord.AlternativeFullDisplayName()) {
          NPCName = LocKeyToString(characterRecord.AlternativeFullDisplayName());
        } else {
          NPCName = LocKeyToString(characterRecord.AlternativeDisplayName());
        };
      } else {
        if this.IsCharacterCivilian() || Equals(characterRecord.BaseAttitudeGroup(), n"child_ow") {
          if IsNameValid(characterRecord.DisplayName()) {
            NPCName = LocKeyToString(characterRecord.DisplayName());
          } else {
            NPCName = this.GetDisplayName();
          };
        } else {
          if IsNameValid(characterRecord.FullDisplayName()) {
            NPCName = LocKeyToString(characterRecord.FullDisplayName());
          } else {
            if IsNameValid(characterRecord.DisplayName()) {
              NPCName = LocKeyToString(characterRecord.DisplayName());
            } else {
              NPCName = this.GetDisplayName();
            };
          };
        };
      };
      if nameChunk.HasArchetype() {
        nameParams = new inkTextParams();
        if Equals(NPCName, ToString(archetypeName)) || !IsNameValid(characterRecord.FullDisplayName()) && !IsNameValid(characterRecord.DisplayName()) {
          NPCName = "";
        };
        nameParams.AddLocalizedString("TEXT_PRIMARY", NPCName);
        nameParams.AddLocalizedString("TEXT_SECONDARY", ToString(archetypeName));
        nameChunk.SetTextParams(nameParams);
        archtypeChunk = new ScannerArchetype();
        archtypeChunk.Set(characterRecord.ArchetypeData().Type().Type());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerArchetype, ToVariant(archtypeChunk));
      } else {
        nameChunk.Set(NPCName);
      };
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, ToVariant(nameChunk));
    };

    if this.IsCrowd() && !characterRecord.IsChild() {    
        let descriptionString = this.GenerateCharacterBackground();
        descriptionChunk = new ScannerVehicleInfo();
        descriptionChunk.Set(descriptionString);
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleInfo, ToVariant(descriptionChunk));
    }

    if scannerPreset.ShouldShowLevel() {
      levelChunk = new ScannerLevel();
      levelChunk.Set(0);
      levelChunk.SetIndicator(NPCPuppet.ShouldShowIndicator(thisEntity));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerLevel, ToVariant(levelChunk));
    };
    if scannerPreset.ShouldShowRarity() {
      rarityChunk = new ScannerRarity();
      hasLinkToDB = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HasLinkToBountySystem) > 0.00;
      rarityChunk.Set(this.GetPuppetRarity().Type(), this.IsCharacterCivilian() && hasLinkToDB);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerRarity, ToVariant(rarityChunk));
    };
    if scannerPreset.ShouldShowFaction() {
      factionChunk = new ScannerFaction();
      factionChunk.Set(LocKeyToString(characterRecord.Affiliation().LocalizedName()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerFaction, ToVariant(factionChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowAttitude() {
      attitudeChunk = new ScannerAttitude();
      attitudeChunk.Set(this.GetAttitudeTowards(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAttitude, ToVariant(attitudeChunk));
    };
    if scannerPreset.ShouldShowHealth() {
      healthChunk = new ScannerHealth();
      statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetGame());
      if !Equals(statPoolSystem, null) {
        healthChunk.Set(Cast(statPoolSystem.GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, false)), Cast(GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolMaxPointValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health)));
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerHealth, ToVariant(healthChunk));
      };
    };
    if scannerPreset.ShouldShowBounty() && TDBID.IsValid(this.GetRecord().BountyDrawTable().GetID()) {
      if ArraySize(this.m_bounty.m_transgressions) < 0 {
        BountyManager.GenerateBounty(this);
      };
      bountyChunk = new ScannerBountySystem();
      bountyUI.issuedBy = LocKeyToString(TweakDBInterface.GetAffiliationRecord(this.m_bounty.m_bountySetter).LocalizedName());
      bountyUI.moneyReward = this.m_bounty.m_moneyAmount;
      bountyUI.streetCredReward = this.m_bounty.m_streetCredAmount;
      enemyDifficulty = RPGManager.CalculatePowerDifferential(thisEntity);
      if Equals(enemyDifficulty, EPowerDifferential.TRASH) {
        bountyUI.level = 1;
      };
      if Equals(enemyDifficulty, EPowerDifferential.EASY) {
        bountyUI.level = 2;
      };
      if Equals(enemyDifficulty, EPowerDifferential.NORMAL) {
        bountyUI.level = 3;
      };
      if Equals(enemyDifficulty, EPowerDifferential.HARD ){
        bountyUI.level = 4;
      };
      if Equals(enemyDifficulty, EPowerDifferential.IMPOSSIBLE) {
        bountyUI.level = 5;
      };
      bountyUI.hasAccess = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HasLinkToBountySystem) > 0.00;
      i = 0;
      while i < ArraySize(this.m_bounty.m_transgressions) {
        ArrayPush(bountyUI.transgressions, TweakDBInterface.GetTransgressionRecord(this.m_bounty.m_transgressions[i]).LocalizedDescription());
        i += 1;
      };
      bountyChunk.Set(bountyUI);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerBountySystem, ToVariant(bountyChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowWeaponData() {
      AIActionTransactionSystem.CalculateEquipmentItems(this, this.GetRecord().PrimaryEquipment(), items, -1);
      if false {
        detailedWeaponChunk = new ScannerWeaponDetailed();
        detailedWeaponChunk.Set(items[0].Item().DisplayName());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerWeaponDetailed, ToVariant(detailedWeaponChunk));
      } else {
        basicWeaponChunk = new ScannerWeaponBasic();
        basicWeaponChunk.Set(items[0].Item().DisplayName());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerWeaponBasic, ToVariant(basicWeaponChunk));
      };
    };
    if !this.IsDead() && !this.IsCrowd() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowVulnerabilities() {
      vulnerabilitiesChunk = new ScannerVulnerabilities();
      availablePlayerActions = RPGManager.GetPlayerQuickHackList(GetPlayer(this.GetGame()));
      context = this.GetPS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), Device.GetPlayerMainObjectStatic(this.GetGame()), this.GetEntityID());
      ArrayResize(quickHackActionRecords, ArraySize(availablePlayerActions));
      i = 0;
      while i < ArraySize(availablePlayerActions) {
        quickHackActionRecords[i] = TweakDBInterface.GetObjectActionRecord(availablePlayerActions[i]);
        i += 1;
      };
      this.GetPS().GetValidChoices(quickHackActionRecords, context, null, false, choices);
      i = 0;
      while i < ArraySize(choices) {
        k = 0;
        while k < ArraySize(choices[i].data) {
            let v: ref<ScriptableDeviceAction> = FromVariant(choices[i].data[k]);
            puppetQuickHack = v.GetObjectActionRecord();
            if !Equals(puppetQuickHack, null) {
                vulnerability.vulnerabilityName = puppetQuickHack.ObjectActionUI().Caption();
                vulnerability.icon = puppetQuickHack.ObjectActionUI().CaptionIcon().EnumName();
                z = 0;
                while z < ArraySize(quickHackActionRecords) {
                if quickHackActionRecords[z].GameplayCategory().GetID() == puppetQuickHack.GetID() {
                    vulnerability.isActive = true;
                };
                z += 1;
                };
                vulnerabilitiesChunk.PushBack(vulnerability);
            };
            k += 1;
        };
        i += 1;
      };
      if vulnerabilitiesChunk.IsValid() {
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVulnerabilities, ToVariant(vulnerabilitiesChunk));
      };
    };
    if scannerPreset.ShouldShowNetworkStatus() {
      networkStatusChunk = new ScannerNetworkStatus();
      ap = this.GetPS().GetAccessPoint();
      if !Equals(ap, null) {
        if ap.IsBreached() {
          networkStatusChunk.Set(ScannerNetworkState.BREACHED);
        } else {
          networkStatusChunk.Set(ScannerNetworkState.NOT_BREACHED);
        };
      } else {
        networkStatusChunk.Set(ScannerNetworkState.NOT_CONNECTED);
      };
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowResistances() {
      resistancesChunk = new ScannerResistances();
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.PhysicalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ThermalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ElectricResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ChemicalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.HackingResistance, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject()));
      resistancesChunk.Set(resists);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerResistances, ToVariant(resistancesChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) {
      abilityChunk = new ScannerAbilities();
      archetypeData = characterRecord.ArchetypeData();
      if Equals(archetypeData, null) {
        return false;
      };
      if archetypeData.GetAbilityGroupsCount() > 0 {
        archetypeData.AbilityGroups(abilityGroups);
        i = 0;
        while i < ArraySize(abilityGroups) {
          abilityGroups[i].Abilities(abilities);
          abilityChunk.Set(abilities);
          scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAbilities, ToVariant(abilityChunk));
          i += 1;
        };
      };
    };
    return true;
  }

@replaceMethod(scannerDetailsGameController)
public final func RefreshLayout() -> Void {
    this.BreakAniamtions();
    if NotEquals(HUDManager.GetActiveMode(this.m_gameInstance), ActiveMode.FOCUS) {
        this.PlayCloseScannerAnimation();
    };
    if Equals(this.m_scanningState, gameScanningState.Complete) || Equals(this.m_scanningState, gameScanningState.ShallowComplete) || Equals(this.m_scanningState, gameScanningState.Started) {
        inkCompoundRef.RemoveAllChildren(this.m_scannerCountainer);
        inkCompoundRef.RemoveAllChildren(this.m_fllufContainer);
        inkCompoundRef.RemoveAllChildren(this.m_quickhackContainer);
        inkWidgetRef.SetVisible(this.m_bg, true);
        this.GetRootWidget().SetVisible(false);
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_quickhackContainer), n"QuickHackDescription");
        if Equals(this.m_scannedObjectType, ScannerObjectType.PUPPET) {
            this.GetRootWidget().SetVisible(true);
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerNPCHeaderWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerNPCBodyWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerSquadInfoWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerBountySystemWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerRequirementsWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerAbilitiesWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerResistancesWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceDescriptionWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerVehicleBody");
        };
        if Equals(this.m_scannedObjectType, ScannerObjectType.DEVICE) {
            this.GetRootWidget().SetVisible(true);
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceHeaderWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerVulnerabilitiesWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerRequirementsWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceDescriptionWidget");
        };
        if Equals(this.m_scannedObjectType, ScannerObjectType.VEHICLE) {
            this.GetRootWidget().SetVisible(true);
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerVehicleBody");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceDescriptionWidget");
        };
        if Equals(this.m_scannedObjectType, ScannerObjectType.GENERIC) {
            this.GetRootWidget().SetVisible(true);
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceHeaderWidget");
            this.SpawnFromLocal(inkWidgetRef.Get(this.m_scannerCountainer), n"ScannerDeviceDescriptionWidget");
            inkWidgetRef.SetVisible(this.m_toggleDescirptionHackPart, false);
        };
        this.m_showScanAnimProxy = this.PlayLibraryAnimation(n"intro");
        this.m_showScanAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScannerDetailsShown");
    };
    if Equals(this.m_scanningState, gameScanningState.Stopped) || Equals(this.m_scanningState, gameScanningState.Default) {
        this.PlayCloseScannerAnimation();
    };
}

@replaceMethod(ScannervehicleGameController)
protected cb func OnVehicleInfoChanged(value: Variant) -> Bool {
    let vehicleInfoData: ref<ScannerVehicleInfo>;
    vehicleInfoData = FromVariant(value);
    if !Equals(vehicleInfoData, null) {
        inkTextRef.SetLocalizedTextScriptAndFallback(this.m_vehicleInfoText, vehicleInfoData.GetVehicleInfo());
        this.m_isValidVehicleInfo = true;
    } else {
        this.m_isValidVehicleInfo = false;
    };
    this.UpdateGlobalVisibility();
}
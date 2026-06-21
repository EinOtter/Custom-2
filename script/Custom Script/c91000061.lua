--Summon as monster
if op==0 then
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	c:AddMonsterAttributeComplete()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(RACE_CYBERSE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_DARK)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(4)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetValue(1200)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(1200)
	e5:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e5)

	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		--Immediately Link Summon a Cyberse Link Monster
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_EXTRA_MATERIAL)
		e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e6:SetTargetRange(1,0)
		e6:SetValue(s.extraval)
		e6:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e6,tp)

		--Cyberse lock
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e7:SetTargetRange(1,0)
		e7:SetTarget(s.splimit)
		e7:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e7,tp)

		aux.RegisterClientHint(c,nil,tp,1,0,
			"Immediately after this effect resolves, you can Link Summon a Cyberse Link Monster.")
	end
end
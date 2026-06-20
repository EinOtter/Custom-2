--Valhalla, Nordic Celestial Haven
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Add 1 "Nordic" monster, then discard 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	--Aesir protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--Token Summon and Level Reduce
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.toktg)
	e3:SetOperation(s.tokop)
	c:RegisterEffect(e3)
end

--(1) Activate: Search and discard
function s.filter(c)
	return c:IsSetCard(SET_NORDIC) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end

--(2) Aesir protection
function s.indtg(e,c)
	return c:IsSetCard(SET_AESIR)
end

--(3) Level reduce and Token summon
function s.tokfilter(c)
	return c:IsSetCard(SET_NORDIC) and c:IsLevelAbove(3)
end
function s.toktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(s.tokfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,91000038,0,TYPE_TOKEN+TYPE_MONSTER,2000,2000,2,RACE_WARRIOR,ATTRIBUTE_LIGHT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tokfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)  -- Optional, helps for UI
end

function s.tokop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLevelAbove(3) then
		local lv=tc:GetLevel()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(lv-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if Duel.IsPlayerCanSpecialSummonMonster(tp,91000038,0,TYPES_TOKEN_MONSTER,2000,2000,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
    	local token=Duel.CreateToken(tp,91000038)
    	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
